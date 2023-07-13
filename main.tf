terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
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
  # We'll set gandi_zone to true if var.dns_type has a value of "gandi"
  gandi_zone = var.dns_type == "gandi" ? true : false

  # Break up the hostname
  fqdn_bits   = split(".", var.website_hostname)
  fqdn_length = length(local.fqdn_bits)
  hostname    = slice(local.fqdn_bits, 0, 1)[0]                         # First element is hostname
  domain      = join(".", slice(local.fqdn_bits, 1, local.fqdn_length)) # Remainder is domain

  # Coalesce data for certificate and DNS
  certificate_validation_arn          = one(coalescelist(aws_acm_certificate_validation.site-aws[*].certificate_arn, aws_acm_certificate_validation.site-gandi[*].certificate_arn))
  certificate_validation_record_fqdns = one(coalescelist(aws_acm_certificate_validation.site-aws[*].validation_record_fqdns, aws_acm_certificate_validation.site-gandi[*].validation_record_fqdns))
  dns-site-id                         = coalescelist(aws_route53_record.site[*].id, gandi_livedns_record.site[*].id, [""])
  dns-site-name                       = one(coalescelist(aws_route53_record.site[*].name, gandi_livedns_record.site[*].name, [""]))
  dns-site-alias                      = coalescelist(aws_route53_record.site[*].alias, gandi_livedns_record.site[*].values, [""])

  # Tags
  tags = {
    app = var.website_hostname
  }
}

# Bucket Policy Document
# Allow access to CloudFront ARN via Origin Access Control
data "aws_iam_policy_document" "cloudfront_readonly" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
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
  count                   = local.gandi_zone ? 1 : 0
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in aws_route53_record.site-validation : record.fqdn]
}

resource "aws_acm_certificate_validation" "site-gandi" {
  provider                = aws.use1
  count                   = local.gandi_zone ? 0 : 1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in gandi_livedns_record.site-validation : record.name]
}

# DNS
# Create AWS Route 53 records if local.gandi_zone is false
resource "aws_route53_record" "site" {
  count   = local.gandi_zone ? 0 : 1
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
    } if !local.gandi_zone
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
  count  = local.gandi_zone ? 1 : 0
  name   = local.hostname
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
    } if local.gandi_zone
  }

  name   = trimsuffix(each.value.name, ".${local.domain}.")
  zone   = local.domain
  ttl    = 600
  type   = each.value.type
  values = [each.value.record]
}

# S3 Bucket, and config, for holding static files
resource "aws_s3_bucket" "site" {
  provider      = aws
  bucket        = var.website_hostname
  force_destroy = var.force_destroy_bucket
  tags          = local.tags
}

resource "aws_s3_bucket_versioning" "site" {
  count    = var.bucket_versioning ? 1 : 0
  provider = aws
  bucket   = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "site" {
  provider = aws
  bucket   = aws_s3_bucket.site.id
  policy   = data.aws_iam_policy_document.cloudfront_readonly.json
}

# Cloudfront distribution
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  provider            = aws
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class
  aliases             = [var.website_hostname]

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
    allowed_methods  = var.cloudfront_cache_allowed_methods
    cached_methods   = var.cloudfront_cached_methods
    target_origin_id = "S3-${var.website_hostname}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = var.cloudfront_min_ttl
    default_ttl = var.cloudfront_default_ttl
    max_ttl     = var.cloudfront_max_ttl
    compress    = true
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
      locations        = var.cloudfront_geo_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.certificate_validation_arn
    minimum_protocol_version = var.cloudfront_viewer_security_policy
    ssl_support_method       = var.cloudfront_viewer_ssl_support_method
  }

  tags = local.tags
}
