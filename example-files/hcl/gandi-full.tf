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
  source           = "garyrule/static-website/aws"
  version          = "0.0.3"
  dns_type         = "gandi"
  gandi_key        = var.gandi_key
  website_hostname = var.website_hostname
  region           = "us-west-1"

  #------------------
  # S3
  #------------------
  # Website
  bucket_website_versioning    = true
  bucket_website_key_enabled   = true
  bucket_website_force_destroy = false
  bucket_website_sse_algo      = "AES256"

  # Logs
  bucket_cloudfront_logs_versioning    = false
  bucket_cloudfront_logs_key_enabled   = true
  bucket_cloudfront_logs_force_destroy = true
  bucket_cloudfront_logs_sse_algo      = "AES256"

  #------------------
  # CloudFront
  #------------------
  cloudfront_enabled              = true
  cloudfront_retain_on_delete     = false
  cloudfront_comment              = "my website"
  cloudfront_default_root_object  = "index.html"
  cloudfront_ipv6_enabled         = true
  cloudfront_wait_for_deployment  = false
  cloudfront_price_class          = "PriceClass_100"
  cloudfront_maximum_http_version = "http3"

  ## Cache
  cloudfront_cache_max_ttl                               = 86400
  cloudfront_cache_min_ttl                               = 0
  cloudfront_cache_default_ttl                           = 3600
  cloudfront_cache_allowed_methods                       = ["GET", "HEAD"]
  cloudfront_cached_methods                              = ["GET", "HEAD"]
  cloudfront_cache_compress                              = true
  cloudfront_cache_policy_cookie_behavior                = "none"
  cloudfront_cache_policy_header_behavior                = "none"
  cloudfront_cache_policy_cookies                        = []
  cloudfront_cache_policy_headers                        = []
  cloudfront_cache_behavior_viewer_protocol_policy       = "redirect-to-https"
  cloudfront_cache_behavior_function_associations        = []
  cloudfront_cache_behavior_lambda_function_associations = []

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

  ## SSL
  cloudfront_viewer_ssl_support_method = "sni-only"
  cloudfront_viewer_security_policy    = "TLSv1.2_2021"

  ## Origin
  cloudfront_origin_connection_timeout  = 4
  cloudfront_origin_connection_attempts = 3
  cloudfront_origin_custom_headers = [
    {
      name  = "X-Frame-Options"
      value = "SAMEORIGIN"
    },
    {
      name  = "X-XSS-Protection"
      value = "1; mode=block"
    }
  ]

  ## Custom Error Response
  cloudfront_custom_error_min_ttl                = 0
  cloudfront_custom_error_response_error_code    = 404
  cloudfront_custom_error_response_page_path     = "/error.html"
  cloudfront_custom_error_response_response_code = 200
}
