terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
    gandi = {
      source  = "go-gandi/gandi"
      version = "= 2.2.3"
    }
  }
}

provider "gandi" {
  key        = var.gandi_key
  sharing_id = var.gandi_sharing_id
}

provider "aws" {
  region = var.region
}

# Provider used for ACM
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

locals {
  #------------------------------
  # Input Validation
  #------------------------------
  # If the user specifies a value for var.dns_type == "aws" then the
  # variables var.route53_zone_id and var.website_hostname must not be empty.
  #
  # Similarly, if the user specifies a value for var.dns_type == "gandi" then the
  # variables var.gandi_key and var.website_hostname must not be empty.

  # Unfortunately I don't know how to effectively use this to halt the apply process.
  # However, the output can be evaluated by some other mechanism prior to an apply.
  # See the doc/VALIDATION_CHECK.md for more information.
  validate_inputs = (
    var.dns_type == "aws" && var.route53_zone_id != "" && var.website_hostname != ""
    ) || (
    var.dns_type == "gandi" && var.gandi_key != "" && var.website_hostname != ""
  )

  # Are we using Gandi or AWS?
  gandi_zone = var.dns_type == "gandi" ? true : false

  # Buckets, Policies, etc. don't allow dots in names
  website_name_dashed = replace(var.website_hostname, ".", "-")

  # Break up the hostname and create hostname and domain
  fqdn_bits   = split(".", var.website_hostname)
  fqdn_length = length(local.fqdn_bits)
  hostname    = slice(local.fqdn_bits, 0, 1)[0]                         # First element is hostname
  domain      = join(".", slice(local.fqdn_bits, 1, local.fqdn_length)) # Remainder is domain

  # Grab the website DNS record ID.
  website-domain-resource-id = coalescelist(
    aws_route53_record.site[*].id,
    gandi_livedns_record.site[*].id
  )

  # Build website-domain-target
  route53-website-alias = [for record in aws_route53_record.site : lookup(record.alias[0], "name", null)]
  gandi-website-values  = tolist(length(gandi_livedns_record.site) > 0 ? element(gandi_livedns_record.site[*].values, 0) : [])
  website-domain-target = coalescelist(local.route53-website-alias, local.gandi-website-values)
  website-dns-record    = one(coalescelist(aws_route53_record.site[*].name, gandi_livedns_record.site[*].name))

  certificate_validation_arn         = one(coalescelist(aws_acm_certificate_validation.site-aws[*].certificate_arn, aws_acm_certificate_validation.site-gandi[*].certificate_arn))
  bucket_cloudfront_logs_id          = one(aws_s3_bucket.cloudfront_logs[*].id)
  bucket_cloudfront_logs_domain_name = one(aws_s3_bucket.cloudfront_logs[*].bucket_domain_name)

  # Tags
  tags = {
    app = var.website_hostname
  }
}

# ACM Certificate
resource "aws_acm_certificate" "site" {
  provider          = aws.use1
  domain_name       = var.website_hostname
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = local.tags
}

# We'll use either Gandi or AWS records depending on the value of local.gandi_zone.
resource "aws_acm_certificate_validation" "site-aws" {
  provider                = aws.use1
  count                   = local.gandi_zone == true ? 0 : 1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in aws_route53_record.site-validation : record.fqdn]
}

resource "aws_acm_certificate_validation" "site-gandi" {
  provider                = aws.use1
  count                   = local.gandi_zone == true ? 1 : 0
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in gandi_livedns_record.site-validation : "${record.name}.${local.domain}"]
}

# DNS
# Create AWS Route 53 records if local.gandi_zone is false
resource "aws_route53_record" "site" {
  count   = local.gandi_zone == true ? 0 : 1
  zone_id = var.route53_zone_id
  name    = var.website_hostname
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site-validation" {
  for_each = {
    for option in aws_acm_certificate.site.domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    } if local.gandi_zone == false
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = var.route53_zone_id
  ttl             = 60
}

# Create Gandi LiveDNS records if local.gandi_zone is true
resource "gandi_livedns_record" "site" {
  count  = local.gandi_zone == true ? 1 : 0
  name   = local.hostname # Gandi doesn't use/store records fully qualified
  zone   = local.domain
  type   = "CNAME"
  ttl    = 600
  values = ["${aws_cloudfront_distribution.site.domain_name}."]
}

resource "gandi_livedns_record" "site-validation" {
  for_each = {
    for option in aws_acm_certificate.site.domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    } if local.gandi_zone == true
  }

  # Gandi doesn't store the records fully qualified
  name   = trimsuffix(each.value.name, ".${local.domain}.")
  zone   = local.domain
  ttl    = 600
  type   = each.value.type
  values = [each.value.record]
}

#------------------------------
# S3 Bucket for Static Assets
#------------------------------
# Bucket Policy Document for static assets access
data "aws_iam_policy_document" "cloudfront_readonly" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.site.arn,
      "${aws_s3_bucket.site.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket" "site" {
  bucket        = local.website_name_dashed
  force_destroy = var.bucket_website_force_destroy
  tags          = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  #bucket = local.website_name_dashed
  bucket = aws_s3_bucket.site.id
  rule {
    # Always set the bucket_key_enabled value
    bucket_key_enabled = var.bucket_website_key_enabled

    # Only set the algorithm and KMS key ID if a KMS key ID is provided
    dynamic "apply_server_side_encryption_by_default" {
      for_each = var.bucket_website_sse_algo == "aws:kms" ? [1] : []
      content {
        sse_algorithm     = var.bucket_website_sse_algo
        kms_master_key_id = var.bucket_website_sse_kms_key_id
      }
    }
    # Otherwise, set the algorithm to AES256
    dynamic "apply_server_side_encryption_by_default" {
      for_each = var.bucket_website_sse_algo == "aws:kms" ? [] : [1]
      content {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "site" {
  count  = var.bucket_website_versioning ? 1 : 0
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = var.bucket_website_policy == "" ? data.aws_iam_policy_document.cloudfront_readonly.json : var.bucket_website_policy
}

##------------------------------
## S3 Bucket for Cloudfront Logs
##------------------------------
resource "aws_s3_bucket" "cloudfront_logs" {
  count         = var.cloudfront_logging ? 1 : 0
  bucket        = "${local.website_name_dashed}-logging"
  force_destroy = var.bucket_cloudfront_logs_force_destroy
  tags          = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  count  = var.cloudfront_logging ? 1 : 0
  bucket = aws_s3_bucket.cloudfront_logs[0].id
  rule {
    # Always set the bucket_key_enabled value
    bucket_key_enabled = var.bucket_cloudfront_logs_key_enabled

    # Only set the algorithm and KMS key ID if a KMS key ID is provided
    dynamic "apply_server_side_encryption_by_default" {
      for_each = var.bucket_cloudfront_logs_sse_algo == "aws:kms" ? [1] : []
      content {
        sse_algorithm     = var.bucket_cloudfront_logs_sse_algo
        kms_master_key_id = var.bucket_cloudfront_logs_sse_kms_key_id
      }
    }
    # Otherwise, set the algorithm to AES256
    dynamic "apply_server_side_encryption_by_default" {
      for_each = var.bucket_cloudfront_logs_sse_algo == "aws:kms" ? [] : [1]
      content {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  count  = var.bucket_cloudfront_logs_versioning ? 1 : 0
  bucket = one(aws_s3_bucket.cloudfront_logs[*].id)
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  count  = var.cloudfront_logging ? 1 : 0
  bucket = local.bucket_cloudfront_logs_id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "cloudfront_logs" {
  count  = var.cloudfront_logging ? 1 : 0
  bucket = local.bucket_cloudfront_logs_id
  acl    = "private"

  depends_on = [
    aws_s3_bucket.cloudfront_logs,
    aws_s3_bucket_ownership_controls.cloudfront_logs,
  ]
}

# CloudFront distribution
resource "aws_cloudfront_cache_policy" "site" {
  name        = local.website_name_dashed
  min_ttl     = var.cloudfront_cache_min_ttl
  default_ttl = var.cloudfront_cache_default_ttl
  max_ttl     = var.cloudfront_cache_max_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = var.cloudfront_cache_policy_cookie_behavior
      dynamic "cookies" {
        for_each = length(var.cloudfront_cache_policy_cookies) > 0 ? [var.cloudfront_cache_policy_cookies] : []
        content {
          items = cookies.value
        }
      }
    }
    headers_config {
      header_behavior = var.cloudfront_cache_policy_header_behavior
      dynamic "headers" {
        for_each = length(var.cloudfront_cache_policy_headers) > 0 ? [var.cloudfront_cache_policy_headers] : []
        content {
          items = headers.value
        }
      }
    }
    query_strings_config {
      query_string_behavior = var.cloudfront_cache_policy_query_string_behavior
      dynamic "query_strings" {
        for_each = length(var.cloudfront_cache_policy_query_strings) > 0 ? [var.cloudfront_cache_policy_query_strings] : []
        content {
          items = query_strings.value
        }
      }
    }
  }
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = var.cloudfront_enabled
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class
  aliases             = [var.website_hostname]
  http_version        = var.cloudfront_maximum_http_version

  dynamic "logging_config" {
    for_each = var.cloudfront_logging ? [1] : []
    content {
      bucket          = local.bucket_cloudfront_logs_domain_name
      prefix          = var.cloudfront_logging_prefix == "" ? "${local.website_name_dashed}/" : var.cloudfront_logging_prefix
      include_cookies = var.cloudfront_logging_cookies
    }
  }

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "S3-${var.website_hostname}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/error.html"
  }

  default_cache_behavior {
    allowed_methods        = var.cloudfront_cache_allowed_methods
    cached_methods         = var.cloudfront_cached_methods
    target_origin_id       = "S3-${var.website_hostname}"
    compress               = var.cloudfront_cache_compress
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = aws_cloudfront_cache_policy.site.id
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
      locations        = var.cloudfront_geo_restriction_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.certificate_validation_arn
    minimum_protocol_version = var.cloudfront_viewer_security_policy
    ssl_support_method       = var.cloudfront_viewer_ssl_support_method
  }

  tags = local.tags
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = local.website_name_dashed
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
