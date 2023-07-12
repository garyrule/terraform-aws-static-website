#Required
variable "website_hostname" {
  type        = string
  description = "Fully qualified domain name for website - www.yourdomain.com"
}

# If you're using Route53 you only need to set route53_zone_id
# AWS
variable "route53_zone_id" {
  type        = string
  description = "Route53 Zone ID for website TLD"
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

variable "cloudfront_viewer_security_policy" {
  description = "Which Security Policy to use. Consult this table: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html"
  type        = string
  default     = "TLSv1.2_2021"
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

variable "referer_header" {
  type        = string
  description = "Shared secret that Cloudfront will pass to S3 in order to read the bucket contents"
  default     = ""
}
