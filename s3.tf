#------------------------------
# S3 Buckets
#------------------------------
resource "aws_s3_bucket" "site" {
  bucket        = local.website_name_dashed
  force_destroy = var.bucket_website_force_destroy
  tags          = local.tags
}

# Static Assets
resource "aws_s3_bucket_versioning" "site" {
  count  = var.bucket_website_versioning ? 1 : 0
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = var.bucket_website_policy == "" ? (
  data.aws_iam_policy_document.cloudfront_readonly.json) : var.bucket_website_policy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    # Always set the bucket_key_enabled key
    bucket_key_enabled = var.bucket_website_key_enabled

    # Only set the KMS key ID if a KMS key ID is provided
    dynamic "apply_server_side_encryption_by_default" {
      for_each = var.bucket_website_sse_algo == "aws:kms" ? [1] : []
      content {
        sse_algorithm     = var.bucket_website_sse_algo
        kms_master_key_id = var.bucket_website_sse_kms_key_id
      }
    }
    # Otherwise, set the algorithm to AES256
    dynamic "apply_server_side_encryption_by_default" {
      for_each = var.bucket_website_sse_algo == "aws:kms" ? [] : [1]
      content {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Cloudfront Logs
resource "aws_s3_bucket" "cloudfront_logs" {
  count         = var.cloudfront_logging ? 1 : 0
  bucket        = "${local.website_name_dashed}-logging"
  force_destroy = var.bucket_cloudfront_logs_force_destroy
  tags          = local.tags
}

resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  count  = var.bucket_cloudfront_logs_versioning ? 1 : 0
  bucket = one(aws_s3_bucket.cloudfront_logs[*].id)
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  count  = var.cloudfront_logging ? 1 : 0
  bucket = local.bucket_cloudfront_logs_id
  acl    = "private"

  depends_on = [
    aws_s3_bucket.cloudfront_logs,
    aws_s3_bucket_ownership_controls.cloudfront_logs,
  ]
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  count  = var.cloudfront_logging ? 1 : 0
  bucket = local.bucket_cloudfront_logs_id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  count  = var.cloudfront_logging ? 1 : 0
  bucket = aws_s3_bucket.cloudfront_logs[0].id
  rule {
    # Always set the bucket_key_enabled value
    bucket_key_enabled = var.bucket_cloudfront_logs_key_enabled

    # Only set the algorithm and KMS key ID if a KMS key ID is provided
    dynamic "apply_server_side_encryption_by_default" {
      for_each = var.bucket_cloudfront_logs_sse_algo == "aws:kms" ? [1] : []
      content {
        sse_algorithm     = var.bucket_cloudfront_logs_sse_algo
        kms_master_key_id = var.bucket_cloudfront_logs_sse_kms_key_id
      }
    }

    # Otherwise, set the algorithm to AES256
    dynamic "apply_server_side_encryption_by_default" {
      for_each = var.bucket_cloudfront_logs_sse_algo == "aws:kms" ? [] : [1]
      content {
        sse_algorithm = "AES256"
      }
    }
  }
}
