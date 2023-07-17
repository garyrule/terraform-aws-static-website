#-------------------
# Key Variables
#-------------------
# If you're using AWS Route 53 for DNS then you need to
# set the route53_zone_id variable to the Route 53 Zone ID
# for your website TLD.
#
# The dns_type variable defaults to "aws" so you don't
# need to set it unless you're using Gandi.
#
# If you're using Gandi for DNS then you need to set the
# gandi_key variable to your GandiAPI Key and set the dns_type
# variable to "gandi".
#
# Optionally, and only if needed, you can set the gandi_sharing_id
# See this page for more details: https://api.gandi.net/docs/reference/#Sharing-ID

variable "website_hostname" {
  type        = string
  description = <<EOF
  Fully qualified domain name for website - `static.yourdomain.com`
  EOF

  validation {
    condition     = var.website_hostname != ""
    error_message = "The Variable \"website_hostname\" cannot be blank"
  }
}

variable "dns_type" {
  type        = string
  default     = "aws"
  description = <<EOF
  Either `aws` or `gandi` depending on where your DNS Zone is hosted
  EOF

  validation {
    condition     = var.dns_type == "aws" || var.dns_type == "gandi"
    error_message = <<EOF
    The Variable "dns_type" is invalid. It must be set to
    either "aws" or "gandi"
    EOF
  }
}

# Route 53
variable "route53_zone_id" {
  type        = string
  description = "Route 53 Zone ID for website TLD"
  default     = ""
}

variable "gandi_key" {
  type        = string
  description = "Gandi API Key - Required if using Gandi for DNS"
  default     = ""
}

variable "gandi_sharing_id" {
  type        = string
  description = <<EOF
  Gandi API Sharing ID - Optional
  See:  https://api.gandi.net/docs/reference/#Sharing-ID
  EOF
  default     = ""
}

# Region for S3 Buckets
variable "region" {
  type        = string
  description = "AWS Region to use for S3 Buckets"
  default     = "us-west-2"
}

# ------------------
# CloudFront
# ------------------
variable "cloudfront_enabled" {
  type        = bool
  default     = true
  description = "Enable the Cloudfront Distribution?"
}

variable "cloudfront_price_class" {
  type        = string
  description = <<EOF
  Which CloudFront Price Class to use. Consult this table:
  https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html
  EOF
  default     = "PriceClass_100"

  validation {
    condition = (var.cloudfront_price_class == "PriceClass_All"
      || var.cloudfront_price_class == "PriceClass_200"
    || var.cloudfront_price_class == "PriceClass_100")

    error_message = <<EOF
    The cloudfront_price_class variable must be one of either PriceClass_All,
    PriceClass_200 or PriceClass_100
    EOF
  }
}

variable "cloudfront_cache_allowed_methods" {
  type        = list(string)
  description = <<EOF
  CloudFront Allowed Cache Methods -
  Controls which HTTP methods CloudFront processes and forwards to your Amazon
  S3 bucket or your custom origin.
  EOF
  default     = ["GET", "HEAD"]
}

variable "cloudfront_cached_methods" {
  type        = list(string)
  description = <<EOF
  CloudFront Cached Methods -
  Controls whether CloudFront caches the response to requests using the
  specified HTTP methods.
  EOF
  default     = ["GET", "HEAD"]
}

variable "cloudfront_cache_default_ttl" {
  type        = number
  default     = 3600
  description = <<EOF
  CloudFront Default TTL -
  Default amount of time (in seconds) that an object is in a CloudFront cache
  before CloudFront forwards another request in the absence of an Cache-Control
  max-age or Expires header.
  EOF
}

variable "cloudfront_cache_min_ttl" {
  type        = number
  description = <<EOF
  Specify the minimum amount of time, in seconds, that you want objects to stay
  in the CloudFront cache before CloudFront sends another request to the origin
  to determine whether the object has been updated.
  EOF
  default     = 0
}

variable "cloudfront_cache_max_ttl" {
  type        = number
  description = <<EOF
  Specify the maximum amount of time, in seconds, that you want objects to stay
  in CloudFront caches before CloudFront queries your origin to see whether the
  object has been updated. The value that you specify for Maximum TTL applies
  only when your origin adds HTTP headers such as `Cache-Control max-age`,
  `Cache-Control s-maxage`, or `Expires` to objects.
  EOF
  default     = 86400
}

variable "cloudfront_viewer_security_policy" {
  type        = string
  description = <<EOF
  Which Security Policy to use. Consult this table:
  https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html
  EOF
  default     = "TLSv1.2_2021"
}

variable "cloudfront_viewer_ssl_support_method" {
  type        = string
  description = <<EOF
  Which SSL support method to use. `sni-only` or `vip` supported

  **PLEASE NOTE:** that setting this value to `vip` will incur **significant
  additional charges**.

  Please read this prior to setting this value to `vip`:
  https://aws.amazon.com/cloudfront/pricing/
  EOF
  default     = "sni-only"

  validation {
    condition = (
      var.cloudfront_viewer_ssl_support_method == "sni-only" ||
    var.cloudfront_viewer_ssl_support_method == "vip")

    error_message = <<EOF
    The variable "cloudfront_viewer_ssl_support_method" is invalid. It must
    be set to either "sni-only" or "vip"
    EOF
  }
}

variable "cloudfront_geo_restriction_type" {
  type        = string
  description = <<EOF
  Method that you want to use to restrict distribution of your content by
  country: `none`, `whitelist`, or `blacklist`.
  EOF
  default     = "none"

  validation {
    condition = (var.cloudfront_geo_restriction_type == "none"
      || var.cloudfront_geo_restriction_type == "blacklist"
    || var.cloudfront_geo_restriction_type == "whitelist")

    error_message = <<EOF
    The variable "cloudfront_geo_restriction_type" is invalid. It must be set
    to either "none" or "whitelist" or "blacklist".
    EOF
  }
}

variable "cloudfront_geo_restriction_locations" {
  type        = list(string)
  description = <<EOF
  ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute
  your content (whitelist) or not distribute your content (blacklist).
  See https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 for a list of codes.
  EOF
  default     = []
}

variable "cloudfront_logging" {
  type        = bool
  description = "Whether CloudFront logs requests."
  default     = true
}

variable "cloudfront_logging_prefix" {
  type        = string
  description = <<EOF
  Logging prefix for CloudFront logs. If you don't specify a prefix, the
  prefix will be the website hostname with dashes instead of dots.
  EOF
  default     = ""
}

variable "cloudfront_logging_cookies" {
  type        = bool
  description = "Whether CloudFront logs cookies."
  default     = false
}

variable "cloudfront_maximum_http_version" {
  type        = string
  default     = "http2"
  description = <<EOF
  Maximum HTTP version to support on the distribution. Allowed values are
  `http1.1`, `http2`, `http2and3`, `http3`.
  EOF

  validation {
    condition = (var.cloudfront_maximum_http_version == "http1.1"
      || var.cloudfront_maximum_http_version == "http2"
      || var.cloudfront_maximum_http_version == "http2and3"
    || var.cloudfront_maximum_http_version == "http3")

    error_message = <<EOF
    The variable "cloudfront_maximum_http_version" is invalid. Allowed values
    are "http1.1", "http2", "http2and3", "http3".
    EOF
  }
}

variable "cloudfront_cache_compress" {
  type        = bool
  description = <<EOF
  Whether you want CloudFront to automatically compress content for web
  requests that include `Accept-Encoding: gzip` in the request header
  EOF
  default     = true
}

variable "cloudfront_cache_policy_cookie_behavior" {
  type        = string
  description = <<EOF
  Whether any cookies in viewer requests are included in the cache key and
  automatically included in requests that CloudFront sends to the origin.
  Valid values for cookie_behavior are `none`, `whitelist`, `allExcept`, and
  `all`.
  EOF
  default     = "none"

  validation {
    condition = (var.cloudfront_cache_policy_cookie_behavior == "none"
      || var.cloudfront_cache_policy_cookie_behavior == "whitelist"
      || var.cloudfront_cache_policy_cookie_behavior == "allExcept"
    || var.cloudfront_cache_policy_cookie_behavior == "all")

    error_message = <<EOF
    The variable "cloudfront_cache_policy_cookie_behavior" is invalid.
    Allowed values are "none", "whitelist", "allExcept", and "all".
    EOF
  }
}

variable "cloudfront_cache_policy_header_behavior" {
  type        = string
  description = <<EOF
  Whether any HTTP headers are included in the cache key and automatically
  included in requests that CloudFront sends to the origin. Valid values for
  header_behavior are `none` and `whitelist`.
  EOF
  default     = "none"

  validation {
    condition = (var.cloudfront_cache_policy_header_behavior == "none"
    || var.cloudfront_cache_policy_header_behavior == "whitelist")

    error_message = <<EOF
    The variable "cloudfront_cache_policy_header_behavior" is invalid.
    Allowed values are "none", and "whitelist".
    EOF
  }
}

variable "cloudfront_cache_policy_query_string_behavior" {
  type        = string
  description = <<EOF
  Whether URL query strings in viewer requests are included in the cache key
  and automatically included in requests that CloudFront sends to the origin.
  Valid values for query_string_behavior are `none`, `whitelist`, `allExcept`,
  and `all`.
  EOF
  default     = "none"

  validation {
    condition = (var.cloudfront_cache_policy_query_string_behavior == "none"
      || var.cloudfront_cache_policy_query_string_behavior == "whitelist"
      || var.cloudfront_cache_policy_query_string_behavior == "allExcept"
    || var.cloudfront_cache_policy_query_string_behavior == "all")

    error_message = <<EOF
    The variable "cloudfront_cache_policy_query_string_behavior" is invalid.
    Allowed values are "none", "whitelist" "allExcept" and "all".
    EOF
  }
}

variable "cloudfront_cache_policy_cookies" {
  type        = list(string)
  description = <<EOF
  List of cookie names used by cloudfront_cache_policy_cookie_behavior
  EOF
  default     = []
}

variable "cloudfront_cache_policy_headers" {
  type        = list(string)
  description = <<EOF
  List of header names used by cloudfront_cache_policy_header_behavior
  EOF
  default     = []
}

variable "cloudfront_cache_policy_query_strings" {
  type        = list(string)
  description = <<EOF
  List of query string names used by
  cloudfront_cache_policy_query_string_behavior
  EOF
  default     = []
}

# ------------------
# S3
# ------------------
# Website Static Assets
variable "bucket_website_versioning" {
  type        = bool
  description = "S3 Bucket Versioning for static assets"
  default     = true
}

variable "bucket_website_policy" {
  type        = string
  description = "JSON representation of your custom S3 Bucket Policy for static assets. See \"BUCKET_POLICY.md\" in doc/"
  default     = ""
}

variable "bucket_website_force_destroy" {
  type        = bool
  description = "Force Destroy S3 Bucket?"
  default     = false
}

variable "bucket_website_key_enabled" {
  type        = bool
  description = <<EOF
  S3 Bucket Key Enabled for static assets
  See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
  EOF
  default     = true
}

variable "bucket_website_sse_algo" {
  type        = string
  description = <<EOF
    Website Bucket SSE Algorithm for static assets
    See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/specifying-kms-encryption.html
  EOF
  default     = "AES256"
}

variable "bucket_website_sse_kms_key_id" {
  type        = string
  description = <<EOF
    Website Bucket SSE KMS Key ID for static assets
    See Here: https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/s3_bucket_server_side_encryption_configuration#kms_master_key_id
  EOF
  default     = ""
}

# CloudFront Logs
variable "bucket_cloudfront_logs_versioning" {
  type        = bool
  description = "S3 Bucket Versioning for CloudFront logs"
  default     = false
}

variable "bucket_cloudfront_logs_force_destroy" {
  type        = bool
  description = "Force Destroy S3 Bucket?"
  default     = false
}

variable "bucket_cloudfront_logs_key_enabled" {
  type        = bool
  description = <<EOF
  S3 Bucket Key Enabled for CloudFront logs
  See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
  EOF
  default     = true
}

variable "bucket_cloudfront_logs_sse_algo" {
  type        = string
  description = <<EOF
    Website Bucket SSE Algorithm for CloudFront logs
    See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/specifying-kms-encryption.html
  EOF
  default     = "AES256"
}

variable "bucket_cloudfront_logs_sse_kms_key_id" {
  type        = string
  description = <<EOF
    Website Bucket SSE KMS Key ID for CloudFront logs
    See Here: https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/s3_bucket_server_side_encryption_configuration#kms_master_key_id
  EOF
  default     = ""
}
