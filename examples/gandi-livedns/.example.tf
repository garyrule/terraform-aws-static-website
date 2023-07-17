terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
  }
}

module "site" {
  source           = "git::git@github.com:garyrule/terraform-aws-static-website.git?ref=v0.0.2"
  dns_type         = "gandi"
  gandi_key        = var.gandi_key
  website_hostname = var.website_hostname
  region           = "us-west-1"

  # CloudFront
  cloudfront_enabled = true

  # Cache
  cloudfront_cache_max_ttl                      = 3600
  cloudfront_cache_min_ttl                      = 0
  cloudfront_cache_default_ttl                  = 600
  cloudfront_cache_allowed_methods              = ["GET", "HEAD", "OPTIONS"]
  cloudfront_cached_methods                     = ["GET", "HEAD", "OPTIONS"]
  cloudfront_cache_compress                     = true
  cloudfront_cache_policy_cookie_behavior       = "none"
  cloudfront_cache_policy_header_behavior       = "none"
  cloudfront_cache_policy_query_string_behavior = "none"

  # Geo restrictions
  cloudfront_geo_restriction_type = "whitelist"
  cloudfront_geo_restriction_locations = [
    "US", "MX", "CA", "GB", "DE", "FR",
    "ES", "IT", "JP", "SG", "AU", "NZ"
  ]

  # Logging
  cloudfront_logging         = false
  cloudfront_logging_cookies = false

  # Deployment settings
  cloudfront_price_class            = "PriceClass_100"
  cloudfront_maximum_http_version   = "http2and3"
  cloudfront_viewer_security_policy = "TLSv1.2_2021"

  # S3
  bucket_website_versioning    = false
  bucket_website_key_enabled   = false
  bucket_website_force_destroy = true
  bucket_website_sse_algo      = "AES256"

  bucket_cloudfront_logs_versioning    = false
  bucket_cloudfront_logs_force_destroy = true
  bucket_cloudfront_logs_key_enabled   = false
  bucket_cloudfront_logs_sse_algo      = "AES256"
}
