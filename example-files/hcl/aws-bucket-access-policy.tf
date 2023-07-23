terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
  }
}
# Create your Custom Policy
data "aws_iam_policy_document" "my_custom_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]

    resources = [
      module.site.bucket-website-arn,
      "${module.site.bucket-website-arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.site.cloudfront-distribution-arn]
    }
  }
}


module "site" {
  source           = "garyrule/static-website/aws"
  version          = "0.0.3"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
  region           = "us-east-2"

  # Static asset bucket
  bucket_website_policy = data.aws_iam_policy_document.my_custom_policy.json
}
