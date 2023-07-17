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
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
  region           = "us-east-2"


  # CloudFront
  cloudfront_enabled = true

  # Cache
  cloudfront_cache_max_ttl                = 86400
  cloudfront_cache_min_ttl                = 0
  cloudfront_cache_default_ttl            = 3600
  cloudfront_cache_allowed_methods        = ["GET", "HEAD"]
  cloudfront_cached_methods               = ["GET", "HEAD"]
  cloudfront_cache_compress               = true
  cloudfront_cache_policy_cookie_behavior = "none"
  cloudfront_cache_policy_header_behavior = "none"

  # Allow versionId in the query_string to support S3 versioning
  cloudfront_cache_policy_query_string_behavior = "whitelist"
  cloudfront_cache_policy_query_strings         = ["versionId"]

  # Geo restrictions
  cloudfront_geo_restriction_type      = "blacklist"
  cloudfront_geo_restriction_locations = ["CA"]

  # Logging
  cloudfront_logging         = true
  cloudfront_logging_cookies = false
  cloudfront_logging_prefix  = "r53-prefix/"

  # SSL and Deployment
  cloudfront_price_class            = "PriceClass_200"
  cloudfront_maximum_http_version   = "http3"
  cloudfront_viewer_security_policy = "TLSv1.2_2021"

  # S3
  bucket_website_versioning    = true
  bucket_website_key_enabled   = true
  bucket_website_force_destroy = false
  bucket_website_sse_algo      = "AES256"

  bucket_cloudfront_logs_versioning    = false
  bucket_cloudfront_logs_key_enabled   = true
  bucket_cloudfront_logs_force_destroy = true
  bucket_cloudfront_logs_sse_algo      = "AES256"
}
