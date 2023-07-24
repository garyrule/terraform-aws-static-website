terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
  }
}

# Create a KMS key and Alias
resource "aws_kms_key" "logs" {
  description             = "logs key"
  deletion_window_in_days = 7
  is_enabled              = true
}

resource "aws_kms_alias" "logs" {
  name          = "alias/logs"
  target_key_id = aws_kms_key.logs.key_id
}



# Pass the kms key ARN to the module's bucket_cloudfront_logs_sse_kms_key variable
module "site" {
  source           = "garyrule/static-website/aws"
  version          = "0.1.0"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
  region           = "us-east-2"

  # CloudFront logs bucket
  bucket_cloudfront_logs_versioning     = false
  bucket_cloudfront_logs_key_enabled    = true
  bucket_cloudfront_logs_force_destroy  = true
  bucket_cloudfront_logs_sse_algo       = "AES256"
  bucket_cloudfront_logs_sse_kms_key_id = aws_kms_key.logs.arn

}

# Create a bucket lifecycle configuration for the static assets
resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  bucket = module.site.bucket_cloudfront_logs_id

  rule {
    status = "Enabled"
    id     = "Expire old CloudFront logs"
    # Expire after 90 days
    expiration {
      days = 90
    }

    filter {
      and {
        prefix = module.site.cloudfront_logging_prefix
        tags = {
          rule      = "Expire old CloudFront logs"
          autoclean = "true"
        }
      }
    }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}
