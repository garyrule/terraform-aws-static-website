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
  #______________________________
  # Input Validation
  #______________________________
  # See the doc/VALIDATION_CHECK.md for more information.
  validate_inputs = (
    var.dns_type == "aws" && var.route53_zone_id != "" && var.website_hostname != ""
    ) || (
    var.dns_type == "gandi" && var.gandi_key != "" && var.website_hostname != ""
  )
  #______________________________
  # Are we using Gandi or AWS?
  gandi_zone = var.dns_type == "gandi" ? true : false

  # Buckets, Policies, etc. don't allow dots in names
  website_name_dashed = replace(var.website_hostname, ".", "-")

  # Break up the hostname and create hostname and domain
  fqdn_bits   = split(".", var.website_hostname)
  fqdn_length = length(local.fqdn_bits)
  hostname    = slice(local.fqdn_bits, 0, 1)[0]                         # First element is hostname
  domain      = join(".", slice(local.fqdn_bits, 1, local.fqdn_length)) # Remainder is domain

  # Build website_domain_target
  route53_website_alias = [
    for record in aws_route53_record.site : (lookup(record.alias[0], "name", null))
  ]
  gandi_website_values = tolist(
    length(gandi_livedns_record.site) > 0
    ? element(gandi_livedns_record.site[*].values, 0)
    : []
  )

  website_domain_target = coalescelist(
    local.route53_website_alias,
    local.gandi_website_values
  )

  website_dns_record = one(
    coalescelist(
      aws_route53_record.site[*].name,
      gandi_livedns_record.site[*].name
    )
  )

  # Certificate Validation ARN
  certificate_validation_arn = one(
    coalescelist(
      aws_acm_certificate_validation.site-aws[*].certificate_arn,
      aws_acm_certificate_validation.site-gandi[*].certificate_arn
    )
  )

  # Conditionally created and built with count
  bucket_cloudfront_logs_id          = one(aws_s3_bucket.cloudfront_logs[*].id)
  bucket_cloudfront_logs_domain_name = one(aws_s3_bucket.cloudfront_logs[*].bucket_domain_name)

  # We'll used the dashed hostname unless the user specifies a
  # value for var.cloudfront_logging_prefix
  cloudfront_logging_prefix = var.cloudfront_logging_prefix == "" ? (
  "${local.website_name_dashed}/") : var.cloudfront_logging_prefix

  # Tags
  tags = {
    app = var.website_hostname
  }
}
