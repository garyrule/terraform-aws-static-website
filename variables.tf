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
    condition     = var.website_hostname != "" && length(split(".", var.website_hostname)) > 2
    error_message = <<EOF
    The Variable "website_hostname" cannot be blank and should be fully qualified - static.yourdomain.com
    EOF
  }
}

# DNS
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

variable "route53_zone_id" {
  type        = string
  description = "Route 53 Zone ID for website TLD"
  default     = ""

  validation {
    condition     = can(regex("^$|^Z[a-zA-Z0-9]{13,32}$", var.route53_zone_id))
    error_message = "The route53_zone_id input must be a valid Route 53 Zone ID or an empty string."
  }
}

variable "gandi_key" {
  type        = string
  description = "Gandi API Key - Required if using Gandi for DNS"
  default     = ""

  validation {
    condition     = can(regex("^$|^[a-zA-Z0-9]{10,32}$", var.gandi_key))
    error_message = "The gandi_key input must be a valid Gandi API Key or an empty string."
  }
}

variable "gandi_sharing_id" {
  type        = string
  description = <<EOF
  Gandi API Sharing ID - Optional
  See:  https://api.gandi.net/docs/reference/#Sharing-ID
  EOF
  default     = ""

  validation {
    condition     = can(regex("^$|^[a-zA-Z0-9]{36,64}$", var.gandi_sharing_id))
    error_message = "The gandi_sharing_id input must be a valid Gandi Sharing ID or an empty string."
  }
}

# Region for S3 Buckets
variable "region" {
  type        = string
  description = "AWS Region to use for S3 Buckets"
  default     = "us-west-2"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The region input must be in the format of 'xx-xxxxx-x'."
  }
}

# ------------------
# S3
# ------------------
# Website Static Assets
variable "bucket_website_versioning" {
  type        = bool
  description = "S3 Bucket Versioning for static assets"
  default     = true

  validation {
    condition     = var.bucket_website_versioning == true || var.bucket_website_versioning == false
    error_message = "The bucket_website_versioning variable must be either true or false"
  }
}

variable "bucket_website_policy" {
  type        = string
  description = <<EOF
    JSON representation of your custom S3 Bucket Policy for static assets.
    If blank, the default policy will be used.
  EOF
  default     = ""

  validation {
    condition     = can(jsondecode(var.bucket_website_policy)) || var.bucket_website_policy == ""
    error_message = "The bucket_website_policy variable must be valid JSON from a aws_iam_policy document"
  }
}

variable "bucket_website_force_destroy" {
  type        = bool
  description = "Force Destroy S3 Bucket?"
  default     = false

  validation {
    condition     = var.bucket_website_force_destroy == true || var.bucket_website_force_destroy == false
    error_message = "The bucket_website_force_destroy variable must be either true or false"
  }
}

variable "bucket_website_key_enabled" {
  type        = bool
  description = <<EOF
  S3 Bucket Key Enabled for static assets
  See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
  EOF
  default     = true

  validation {
    condition     = var.bucket_website_key_enabled == true || var.bucket_website_key_enabled == false
    error_message = "The bucket_website_key_enabled variable must be either true or false"
  }
}

variable "bucket_website_sse_algo" {
  type        = string
  description = <<EOF
    Website Bucket SSE Algorithm for static assets
    See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/specifying-kms-encryption.html
  EOF
  default     = "AES256"

  validation {
    condition     = var.bucket_website_sse_algo == "AES256" || var.bucket_website_sse_algo == "aws:kms"
    error_message = "The bucket_website_sse_algo variable must be either AES256 or aws:kms"
  }
}

variable "bucket_website_sse_kms_key_id" {
  type        = string
  description = <<EOF
    Website Bucket SSE KMS Key ARN for static assets
    See Here: https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/s3_bucket_server_side_encryption_configuration#kms_master_key_id
  EOF
  default     = ""

  validation {
    condition = (
      can(
        regex(
          "^$|^arn:aws:kms:[a-z]{2}-[a-z]+-[0-9]:[0-9]{12}:key/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$",
          var.bucket_website_sse_kms_key_id
        )
      )
    )
    error_message = "The bucket_website_sse_kms_key_id input must be a valid ARN or an empty string."
  }
}

# CloudFront Logs
variable "bucket_cloudfront_logs_versioning" {
  type        = bool
  description = "S3 Bucket Versioning for CloudFront logs"
  default     = false

  validation {
    condition = (
      var.bucket_cloudfront_logs_versioning == true
      || var.bucket_cloudfront_logs_versioning == false
    )
    error_message = "The bucket_cloudfront_logs_versioning variable must be either true or false"
  }
}

variable "bucket_cloudfront_logs_force_destroy" {
  type        = bool
  description = "Force Destroy S3 Bucket?"
  default     = false

  validation {
    condition = (
      var.bucket_cloudfront_logs_force_destroy == true
      || var.bucket_cloudfront_logs_force_destroy == false
    )
    error_message = "The bucket_cloudfront_logs_force_destroy variable must be either true or false"
  }
}

variable "bucket_cloudfront_logs_key_enabled" {
  type        = bool
  description = <<EOF
  S3 Bucket Key Enabled for CloudFront logs
  See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
  EOF
  default     = true

  validation {
    condition = (
      var.bucket_cloudfront_logs_key_enabled == true
      || var.bucket_cloudfront_logs_key_enabled == false
    )
    error_message = "The bucket_cloudfront_logs_key_enabled variable must be either true or false"
  }
}

variable "bucket_cloudfront_logs_sse_algo" {
  type        = string
  description = <<EOF
    Website Bucket SSE Algorithm for CloudFront logs
    See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/specifying-kms-encryption.html
  EOF
  default     = "AES256"

  validation {
    condition = (
      var.bucket_cloudfront_logs_sse_algo == "AES256"
      || var.bucket_cloudfront_logs_sse_algo == "aws:kms"
    )
    error_message = "The bucket_cloudfront_logs_sse_algo variable must be either AES256 or aws:kms"
  }
}

variable "bucket_cloudfront_logs_sse_kms_key_id" {
  type        = string
  description = <<EOF
    Website Bucket SSE KMS Key ID for CloudFront logs
    See Here: https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/s3_bucket_server_side_encryption_configuration#kms_master_key_id
  EOF
  default     = ""

  validation {
    condition = (
      can(
        regex("^$|^arn:aws:kms:[a-z]{2}-[a-z]+-[0-9]:[0-9]{12}:key/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$",
          var.bucket_cloudfront_logs_sse_kms_key_id
        )
      )
    )
    error_message = "The bucket_cloudfront_logs_sse_kms_key_id input must be a valid ARN or an empty string."
  }
}

# ------------------
# CloudFront
# ------------------
variable "cloudfront_enabled" {
  type        = bool
  default     = true
  description = "Enable the Cloudfront Distribution?"

  validation {
    condition     = var.cloudfront_enabled == true || var.cloudfront_enabled == false
    error_message = "The cloudfront_enabled variable must be either true or false"
  }
}

variable "cloudfront_ipv6_enabled" {
  type        = bool
  description = <<EOF
    Whether the IPv6 protocol is enabled for the distribution.
  EOF
  default     = true

  validation {
    condition     = var.cloudfront_ipv6_enabled == true || var.cloudfront_ipv6_enabled == false
    error_message = "The cloudfront_ipv6_enabled variable must be either true or false"
  }
}

variable "cloudfront_default_root_object" {
  type        = string
  description = <<EOF
  The default index page that CloudFront will serve when no path is provided.
  EOF
  default     = "index.html"
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

variable "cloudfront_comment" {
  type        = string
  description = <<EOF
    Comment for the CloudFront Distribution
    EOF
  default     = "CloudFront Distribution for Static Website"

  validation {
    condition     = length(var.cloudfront_comment) <= 128
    error_message = <<EOF
        The variable "cloudfront_comment" is invalid. It must be less than 128
        characters.
        EOF
  }
}

variable "cloudfront_wait_for_deployment" {
  type        = bool
  description = <<EOF
  Wait for the CloudFront Distribution to be deployed before continuing.
  EOF
  default     = false

  validation {
    condition     = var.cloudfront_wait_for_deployment == true || var.cloudfront_wait_for_deployment == false
    error_message = "The cloudfront_wait_for_deployment variable must be either true or false"
  }
}

variable "cloudfront_retain_on_delete" {
  type        = bool
  description = <<EOF
    Retain the CloudFront Distribution when the Terraform resource is deleted.
    EOF
  default     = false

  validation {
    condition     = var.cloudfront_retain_on_delete == true || var.cloudfront_retain_on_delete == false
    error_message = "The cloudfront_retain_on_delete variable must be either true or false"
  }
}

variable "cloudfront_origin_custom_headers" {
  type = list(object({
    name  = string
    value = string
  }))

  description = <<EOF
      Custom Headers to send to the origin.
      By default there is a limit of 10 headers. A call to AWS Support can increase
      this limit.
    EOF
  default     = []
  validation {
    # Max values from: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-limits.html#limits-custom-headers
    condition = alltrue([
      for h in var.cloudfront_origin_custom_headers : (
        length(h.name) <= 256 &&
        length(h.value) <= 1783
      )
    ])
    error_message = <<EOF
        The variable "cloudfront_origin_custom_headers" is invalid. The name must be
          less than 100 characters and the value must be less than 200 characters.
    EOF
  }
}

variable "cloudfront_origin_connection_attempts" {
  type        = number
  description = <<EOF
    The number of times that CloudFront attempts to connect to the origin.
  EOF
  default     = 3

  validation {
    condition     = var.cloudfront_origin_connection_attempts >= 1 && var.cloudfront_origin_connection_attempts <= 3
    error_message = <<EOF
        The variable "cloudfront_origin_connection_attempts" is invalid. It must be
        between 1 and 3.
    EOF
  }
}

variable "cloudfront_origin_connection_timeout" {
  type        = number
  description = <<EOF
    The number of seconds that CloudFront waits when trying to establish a
    connection to the origin.
  EOF
  default     = 10

  validation {
    condition     = var.cloudfront_origin_connection_timeout >= 1 && var.cloudfront_origin_connection_timeout <= 10
    error_message = <<EOF
        The variable "cloudfront_origin_connection_timeout" is invalid. It must be
        between 1 and 10.
    EOF
  }
}

variable "cloudfront_cache_behavior_lambda_function_associations" {
  type        = list(map(string))
  description = <<EOF
    A list of Lambda function associations for this cache behavior.
  EOF
  default     = []

  validation {
    condition     = length(var.cloudfront_cache_behavior_lambda_function_associations) <= 4
    error_message = <<EOF
      The variable "cloudfront_cache_behavior_lambda_function_associations" must have 4
      or fewer elements.
    EOF
  }
}

variable "cloudfront_cache_behavior_function_associations" {
  type        = list(map(string))
  description = <<EOF
      A list of function associations for this cache behavior.
  EOF
  default     = []

  validation {
    condition     = length(var.cloudfront_cache_behavior_function_associations) <= 2
    error_message = <<EOF
        The variable "cloudfront_cache_behavior_function_associations" must have 2 or fewer
        elements.
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

  validation {
    condition = alltrue([
      for m in var.cloudfront_cache_allowed_methods : can(regex("^(GET|HEAD|POST|PUT|PATCH|OPTIONS|DELETE)$", m))
    ])
    error_message = <<EOF
        The variable "cloudfront_cache_allowed_methods" is invalid. It must be a
        list of valid HTTP methods.
    EOF
  }

}

variable "cloudfront_cached_methods" {
  type        = list(string)
  description = <<EOF
    CloudFront Cached Methods -
    Controls whether CloudFront caches the response to requests using the
    specified HTTP methods.
  EOF
  default     = ["GET", "HEAD"]

  validation {
    condition = alltrue([
    for m in var.cloudfront_cached_methods : can(regex("^(GET|HEAD|POST|PUT|PATCH|OPTIONS|DELETE)$", m))])
    error_message = <<EOF
      The variable "cloudfront_cached_methods" is invalid. It must be a list of
      valid HTTP methods.
    EOF
  }
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

  validation {
    condition     = var.cloudfront_cache_default_ttl >= 0 && var.cloudfront_cache_default_ttl <= 31536000
    error_message = <<EOF
            The variable "cloudfront_cache_default_ttl" is invalid. It must be
            between 0 and 31536000.
        EOF
  }
}

variable "cloudfront_cache_min_ttl" {
  type        = number
  description = <<EOF
    Specify the minimum amount of time, in seconds, that you want objects to stay
    in the CloudFront cache before CloudFront sends another request to the origin
    to determine whether the object has been updated.
  EOF
  default     = 0

  validation {
    condition     = var.cloudfront_cache_min_ttl >= 0 && var.cloudfront_cache_min_ttl <= 31536000
    error_message = <<EOF
            The variable "cloudfront_cache_min_ttl" is invalid. It must be
            between 0 and 31536000.
        EOF
  }
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

  validation {
    condition     = var.cloudfront_cache_max_ttl >= 0 && var.cloudfront_cache_max_ttl <= 31536000
    error_message = <<EOF
            The variable "cloudfront_cache_max_ttl" is invalid. It must be
            between 0 and 31536000.
        EOF
  }
}

variable "cloudfront_viewer_security_policy" {
  type        = string
  description = <<EOF
  Which Security Policy to use. Consult this table:
  https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html
  EOF
  default     = "TLSv1.2_2021"

  validation {
    condition = (
      var.cloudfront_viewer_security_policy == "TLSv1"
      || var.cloudfront_viewer_security_policy == "TLSv1.1_2016"
      || var.cloudfront_viewer_security_policy == "TLSv1.2_2018"
      || var.cloudfront_viewer_security_policy == "TLSv1.2_2019"
      || var.cloudfront_viewer_security_policy == "TLSv1.2_2021"
    )

    error_message = <<EOF
      The variable "cloudfront_viewer_security_policy" is invalid. Allowed values
      are "TLSv1", "TLSv1.1_2016", "TLSv1.2_2018", "TLSv1.2_2019", "TLSv1.2_2021".
    EOF
  }
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
      var.cloudfront_viewer_ssl_support_method == "sni-only"
      || var.cloudfront_viewer_ssl_support_method == "vip"
    )

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
    condition = (
      var.cloudfront_geo_restriction_type == "none"
      || var.cloudfront_geo_restriction_type == "blacklist"
      || var.cloudfront_geo_restriction_type == "whitelist"
    )

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

  validation {
    condition = alltrue([
      for l in var.cloudfront_geo_restriction_locations : can(regex("^[A-Z]{2}$", l))
    ])
    error_message = <<EOF
      The variable "cloudfront_geo_restriction_locations" is invalid. It must be
      a list of valid ISO 3166-1-alpha-2 codes.
    EOF
  }
}

variable "cloudfront_logging" {
  type        = bool
  description = "Whether CloudFront logs requests."
  default     = true

  validation {
    condition     = var.cloudfront_logging == true || var.cloudfront_logging == false
    error_message = "The cloudfront_logging variable must be either true or false"
  }
}

variable "cloudfront_logging_prefix" {
  type        = string
  description = <<EOF
  Logging prefix for CloudFront logs. If you don't specify a prefix, the
  prefix will be the website hostname with dashes instead of dots.
  EOF
  default     = ""

  validation {
    condition     = length(var.cloudfront_logging_prefix) <= 128
    error_message = <<EOF
          The variable "cloudfront_logging_prefix" is invalid. It must be
          less than 128 characters.
      EOF
  }
}

variable "cloudfront_logging_cookies" {
  type        = bool
  description = "Whether CloudFront logs cookies."
  default     = false

  validation {
    condition     = var.cloudfront_logging_cookies == true || var.cloudfront_logging_cookies == false
    error_message = "The cloudfront_logging_cookies variable must be either true or false"
  }
}

variable "cloudfront_cache_compress" {
  type        = bool
  description = <<EOF
  Whether you want CloudFront to automatically compress content for web
  requests that include `Accept-Encoding: gzip` in the request header
  EOF
  default     = true

  validation {
    condition     = var.cloudfront_cache_compress == true || var.cloudfront_cache_compress == false
    error_message = "The cloudfront_cache_compress variable must be either true or false"
  }
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
    condition = (
      var.cloudfront_cache_policy_cookie_behavior == "none"
      || var.cloudfront_cache_policy_cookie_behavior == "whitelist"
      || var.cloudfront_cache_policy_cookie_behavior == "allExcept"
      || var.cloudfront_cache_policy_cookie_behavior == "all"
    )

    error_message = <<EOF
    The variable "cloudfront_cache_policy_cookie_behavior" is invalid.
    Allowed values are "none", "whitelist", "allExcept", and "all".
    EOF
  }
}

variable "cloudfront_realtime_log_config_arn" {
  type        = string
  description = <<EOF
    The ARN of the Kinesis Firehose stream that receives real-time log data
    from CloudFront.
    EOF
  default     = ""

  validation {
    condition = (
      can(
        regex(
          "^$|^arn:aws:firehose:[a-z]{2}-[a-z]+-[0-9]:[0-9]{12}:deliverystream/[a-zA-Z0-9_-]{1,64}$",
          var.cloudfront_realtime_log_config_arn
        )
      )
    )
    error_message = <<EOF
      The cloudfront_realtime_log_config_arn input must be a valid ARN or an empty string."
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
    condition = (
      var.cloudfront_cache_policy_query_string_behavior == "none"
      || var.cloudfront_cache_policy_query_string_behavior == "whitelist"
      || var.cloudfront_cache_policy_query_string_behavior == "allExcept"
      || var.cloudfront_cache_policy_query_string_behavior == "all"
    )

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

  validation {
    condition = alltrue([
      for c in var.cloudfront_cache_policy_cookies : can(regex("^[a-zA-Z0-9_-]{1,64}$", c))
    ])
    error_message = <<EOF
          The variable "cloudfront_cache_policy_cookies" is invalid. It must be
          a list of valid cookie names.
      EOF
  }
}

variable "cloudfront_cache_policy_headers" {
  type        = list(string)
  description = <<EOF
    List of header names used by cloudfront_cache_policy_header_behavior
  EOF
  default     = []

  validation {
    condition = alltrue([
      for h in var.cloudfront_cache_policy_headers : can(regex("^[a-zA-Z0-9_-]{1,64}$", h))
    ])
    error_message = <<EOF
          The variable "cloudfront_cache_policy_headers" is invalid. It must be
          a list of valid header names.
      EOF
  }
}

variable "cloudfront_cache_policy_query_strings" {
  type        = list(string)
  description = <<EOF
    List of query string names used by
    cloudfront_cache_policy_query_string_behavior
  EOF
  default     = []

  validation {
    condition = alltrue([
      for q in var.cloudfront_cache_policy_query_strings : can(regex("^[a-zA-Z0-9_-]{1,64}$", q))
    ])
    error_message = <<EOF
          The variable "cloudfront_cache_policy_query_strings" is invalid. It must be
          a list of valid query string names.
      EOF
  }
}

# Custom Error Response
variable "cloudfront_custom_error_response_error_code" {
  type        = number
  description = <<EOF
    4xx or 5xx HTTP status code that you want to customize
  EOF
  default     = 404

  validation {
    condition = (
      var.cloudfront_custom_error_response_error_code >= 400
      && var.cloudfront_custom_error_response_error_code <= 599
    )
    error_message = <<EOF
          The variable "cloudfront_custom_error_response_error_code" is invalid. It must be
          between 400 and 599.
      EOF
  }
}

variable "cloudfront_custom_error_response_response_code" {
  type        = number
  description = <<EOF
    The HTTP status code that you want CloudFront to return to the viewer
    along with the custom error page.
  EOF
  default     = 200

  validation {
    condition = (
      var.cloudfront_custom_error_response_response_code >= 200
      && var.cloudfront_custom_error_response_response_code <= 599
    )
    error_message = <<EOF
          The variable "cloudfront_custom_error_response_response_code" is invalid. It must be
          between 200 and 599.
      EOF
  }
}

variable "cloudfront_custom_error_response_page_path" {
  type        = string
  description = <<EOF
   HTML page you want CloudFront to return with the custom error response to the viewer.
  EOF
  default     = "/error.html"

}

variable "cloudfront_custom_error_min_ttl" {
  type        = number
  description = <<EOF
    The minimum amount of time, in seconds, that you want CloudFront to cache
    the HTTP status code specified in ErrorCode.
  EOF
  default     = 0

  validation {
    condition = (
      var.cloudfront_custom_error_min_ttl >= 0
      && var.cloudfront_custom_error_min_ttl <= 31536000
    )
    error_message = <<EOF
          The variable "cloudfront_custom_error_min_ttl" is invalid. It must be
          between 0 and 31536000.
    EOF
  }
}

# Default Cache Behavior
variable "cloudfront_cache_behavior_viewer_protocol_policy" {
  type        = string
  description = <<EOF
    The protocol that viewers can use to access the files in the origin
    specified by TargetOriginId when a request matches the path pattern in
    PathPattern. Valid values are `allow-all`, `redirect-to-https`, and
    `https-only`.
  EOF
  default     = "redirect-to-https"

  validation {
    condition = (var.cloudfront_cache_behavior_viewer_protocol_policy == "allow-all"
      || var.cloudfront_cache_behavior_viewer_protocol_policy == "redirect-to-https"
    || var.cloudfront_cache_behavior_viewer_protocol_policy == "https-only")

    error_message = <<EOF
    The variable "cloudfront_cache_behavior_viewer_protocol_policy" is invalid.
    Allowed values are "allow-all", "redirect-to-https", and "https-only".
    EOF
  }
}

variable "cloudfront_cache_accept_encoding_brotli" {
  type        = bool
  description = <<EOF
        Whether CloudFront caches compressed versions of files in the origin using
        the Brotli compression format.
  EOF
  default     = true

  validation {
    condition = (
      var.cloudfront_cache_accept_encoding_brotli == true
      || var.cloudfront_cache_accept_encoding_brotli == false
    )
    error_message = <<EOF
      The cloudfront_cache_accept_encoding_brotli variable must be either true or false
    EOF
  }
}

variable "cloudfront_cache_accept_encoding_gzip" {
  type        = bool
  description = <<EOF
        Whether CloudFront caches compressed versions of files in the origin using
        the Gzip compression format.
  EOF
  default     = true

  validation {
    condition = (
      var.cloudfront_cache_accept_encoding_gzip == true
      || var.cloudfront_cache_accept_encoding_gzip == false
    )
    error_message = "The cloudfront_cache_accept_encoding_gzip variable must be either true or false"
  }
}

variable "cloudfront_cache_policy_field_level_encryption_id" {
  type        = string
  description = <<EOF
        The ID of the field-level encryption configuration that you want CloudFront
        to use for encrypting specific fields of data for a cache behavior or for
        the default cache behavior in your distribution.
    EOF
  default     = ""

  validation {
    condition = (
      var.cloudfront_cache_policy_field_level_encryption_id == ""
      || (length(var.cloudfront_cache_policy_field_level_encryption_id) > 0
        && length(var.cloudfront_cache_policy_field_level_encryption_id) <= 64
      && can(regex("^\\w+$", var.cloudfront_cache_policy_field_level_encryption_id)))
    )
    error_message = <<EOF
      The cloudfront_cache_policy_field_level_encryption_id must be an empty string or an
      alphanumeric string up to 64 characters.
    EOF
  }
}
