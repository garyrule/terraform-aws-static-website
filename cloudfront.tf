#------------------------------
# CloudFront distribution
#------------------------------
resource "aws_cloudfront_cache_policy" "site" {
  name        = local.website_name_dashed
  min_ttl     = var.cloudfront_cache_min_ttl
  default_ttl = var.cloudfront_cache_default_ttl
  max_ttl     = var.cloudfront_cache_max_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = var.cloudfront_cache_accept_encoding_gzip
    enable_accept_encoding_brotli = var.cloudfront_cache_accept_encoding_brotli
    cookies_config {
      cookie_behavior = var.cloudfront_cache_policy_cookie_behavior
      dynamic "cookies" {
        for_each = length(var.cloudfront_cache_policy_cookies) > 0 ? (
        [var.cloudfront_cache_policy_cookies]) : []
        content {
          items = cookies.value
        }
      }
    }

    headers_config {
      header_behavior = var.cloudfront_cache_policy_header_behavior
      dynamic "headers" {
        for_each = length(var.cloudfront_cache_policy_headers) > 0 ? (
        [var.cloudfront_cache_policy_headers]) : []
        content {
          items = headers.value
        }
      }
    }

    query_strings_config {
      query_string_behavior = var.cloudfront_cache_policy_query_string_behavior
      dynamic "query_strings" {
        for_each = length(var.cloudfront_cache_policy_query_strings) > 0 ? (
        [var.cloudfront_cache_policy_query_strings]) : []
        content {
          items = query_strings.value
        }
      }
    }
  }
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = local.website_name_dashed
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = var.cloudfront_enabled
  is_ipv6_enabled     = var.cloudfront_ipv6_enabled
  default_root_object = var.cloudfront_default_root_object
  price_class         = var.cloudfront_price_class
  aliases             = [var.website_hostname]
  http_version        = var.cloudfront_maximum_http_version
  comment             = var.cloudfront_comment
  retain_on_delete    = var.cloudfront_retain_on_delete
  wait_for_deployment = var.cloudfront_wait_for_deployment
  tags                = local.tags

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "S3-${var.website_hostname}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
    connection_attempts      = var.cloudfront_origin_connection_attempts
    connection_timeout       = var.cloudfront_origin_connection_timeout

    ## Only add custom headers if they are defined
    dynamic "custom_header" {
      for_each = var.cloudfront_origin_custom_headers
      content {
        name  = custom_header.value.name
        value = custom_header.value.value
      }
    }
  }

  # Required
  viewer_certificate {
    acm_certificate_arn      = local.certificate_validation_arn
    minimum_protocol_version = var.cloudfront_viewer_security_policy
    ssl_support_method       = var.cloudfront_viewer_ssl_support_method
  }

  # Add the logging configuration if logging is enabled
  dynamic "logging_config" {
    for_each = var.cloudfront_logging ? [1] : []
    content {
      bucket          = local.bucket_cloudfront_logs_domain_name
      prefix          = local.cloudfront_logging_prefix
      include_cookies = var.cloudfront_logging_cookies
    }
  }

  custom_error_response {
    error_caching_min_ttl = var.cloudfront_custom_error_min_ttl
    error_code            = var.cloudfront_custom_error_response_error_code
    response_code         = var.cloudfront_custom_error_response_response_code
    response_page_path    = var.cloudfront_custom_error_response_page_path
  }

  # Required
  default_cache_behavior {
    allowed_methods           = var.cloudfront_cache_allowed_methods
    cached_methods            = var.cloudfront_cached_methods
    target_origin_id          = "S3-${var.website_hostname}"
    compress                  = var.cloudfront_cache_compress
    viewer_protocol_policy    = var.cloudfront_cache_behavior_viewer_protocol_policy
    cache_policy_id           = aws_cloudfront_cache_policy.site.id
    field_level_encryption_id = var.cloudfront_cache_policy_field_level_encryption_id

    realtime_log_config_arn = var.cloudfront_realtime_log_config_arn != "" ? (
    var.cloudfront_realtime_log_config_arn) : ""

    dynamic "lambda_function_association" {
      for_each = var.cloudfront_cache_behavior_lambda_function_associations
      content {
        event_type   = lambda_function_association.value.event_type
        include_body = lambda_function_association.value.include_body
        lambda_arn   = lambda_function_association.value.lambda_arn
      }
    }

    dynamic "function_association" {
      for_each = var.cloudfront_cache_behavior_function_associations
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
      locations        = var.cloudfront_geo_restriction_locations
    }
  }
}
