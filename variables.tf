#Required
variable "website_hostname" {
  type        = string
  description = "Fully qualified domain name for website - www.yourdomain.com"
}

# If you're using Route 53 you only need to set route53_zone_id
# AWS
variable "route53_zone_id" {
  type        = string
  description = "Route 53 Zone ID for website TLD"
  default     = ""
}

# IF you're using Gandi you need to set both gandi_key and gandi_sharing_id. You'll also need to set dns_type to "gandi"
# GANDI
variable "gandi_key" {
  description = "Gandi API Key"
  type        = string
  default     = ""
}

variable "gandi_sharing_id" {
  description = "Gandi API Sharing ID"
  type        = string
  default     = ""
}

# Defaults
variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-west-2"
}

variable "dns_type" {
  default     = "aws"
  type        = string
  description = "Either \"aws\" or \"gandi\" depending on your DNS set up"
  validation {
    condition     = var.dns_type == "aws" || var.dns_type == "gandi"
    error_message = "The Variable \"dns_type\" is invalid. It must be set to either \"aws\" or \"gandi\""
  }
}

variable "cloudfront_price_class" {
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html
  default     = "PriceClass_100"
  type        = string
  description = "CloudFront edge locations are grouped into geographic regions, and we’ve grouped regions into price classes"
  validation {
    condition     = var.cloudfront_price_class == "PriceClass_All" || var.cloudfront_price_class == "PriceClass_200" || var.cloudfront_price_class == "PriceClass_100"
    error_message = "The cloudfront_price_class varible must be one of either PriceClass_All, PriceClass_200 or PriceClass_100"
  }
}

variable "cloudfront_cache_allowed_methods" {
  default     = ["GET", "HEAD"]
  type        = list(string)
  description = "CloudFront Allowed Cache Methods - Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin."
}

variable "cloudfront_cached_methods" {
  default     = ["GET", "HEAD"]
  type        = list(string)
  description = "CloudFront Cached Methods - Controls whether CloudFront caches the response to requests using the specified HTTP methods."
}

variable "cloudfront_default_ttl" {
  default     = 3600
  type        = number
  description = "CloudFront Default TTL -  Default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header."
}

variable "cloudfront_min_ttl" {
  default     = 0
  type        = number
  description = "CloudFront Minimum TTL"
}

variable "cloudfront_max_ttl" {
  default     = 86400
  type        = number
  description = "CloudFront Maximum TTL"
}

variable "cloudfront_viewer_security_policy" {
  description = "Which Security Policy to use. Consult this table: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "cloudfront_viewer_ssl_support_method" {
  description = "Which SSL support method to use. \"sni-only\" or \"vip\" supported"
  type        = string
  default     = "sni-only"
  validation {
    condition     = var.cloudfront_viewer_ssl_support_method == "sni-only" || var.cloudfront_viewer_ssl_support_method == "vip"
    error_message = "The Variable \"cloudfront_viewer_ssl_support_method\" is invalid. It must be set to either \"sni-only\" or \"vip\""
  }
}

variable "cloudfront_geo_restriction_type" {
  description = ""
  type        = string
  default     = "none"
}

variable "cloudfront_geo_locations" {
  description = ""
  type        = list(string)
  default     = []
}

variable "force_destroy_bucket" {
  type        = bool
  description = "Force Destroy S3 Bucket?"
  default     = false
}

variable "bucket_versioning" {
  type        = bool
  description = "S3 Bucket Versioning?"
  default     = false
}
