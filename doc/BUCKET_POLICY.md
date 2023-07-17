### Update Bucket Policy

* Copy the default aws_iam_policy_document data source and make changes to it
* Add it to your plan
* Edit `bucket_website_policy` variable make the value your new policy document


The below example adds support for get/put object tagging.

```hcl
# Create your Policy
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

# Include it as a variable to the module
module "site" {
  source           = "git::git@github.com:garyrule/terraform-aws-static-website.git?ref=vx.x.x"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
  bucket_website_policy = data.aws_iam_policy_document.my_custom_policy.json
}

```
