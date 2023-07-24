
<!-- BEGIN_TF_DOCS -->


## Instructions

### Create Input Variables
 Create `terraform.tfvars` with the required input variables

##### Set the hostname for the website
* `website_hostname`

##### AWS Route 53
* `route53_zone_id`

##### Gandi LiveDNS
* `dns_type` set to "gandi"
* `gandi_key`

### Edit Configuration - Optional
Edit `main.tf` and change inputs to match your requirements.

See [Example](#examples) for more information.

### Deploy Website
#### Initialize terraform

`$ terraform init`

#### Create the plan

`$ terraform plan -var-file terraform.tfvars -out tfplan.out`

#### Apply the plan

`$ terraform apply tfplan.out`

### Static Assets
This module does not sync static assets for you.
See [Static Assets](../../doc/STATIC_ASSETS.md) for more information.

## Examples
### AWS Route 53 Minimal Example
This is the bare minimum configuration need to deploy a website using Route 53
```hcl
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
  version          = "0.1.0"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
}
```
### AWS Route 53 Example with a Custom Bucket Access Policy
```hcl
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
  version          = "0.1.0"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
  region           = "us-east-2"

  # Static asset bucket
  bucket_website_policy = data.aws_iam_policy_document.my_custom_policy.json
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
      module.site.bucket_website_arn,
      "${module.site.bucket_website_arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.site.cloudfront_distribution_arn]
    }
  }
}
```
### AWS Route 53 Example with Bucket Lifecycle Policy and KMS Key for Encryption
```hcl
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
```

### AWS Route 53 Full Example
Not every option is passed but this will provide an example of a full configuration.
```hcl
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
  version          = "0.1.0"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
  region           = "us-east-2"

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
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Zone ID of Route 53 Zone that we are using to host this website | `string` | n/a | yes |
| <a name="input_website_hostname"></a> [website\_hostname](#input\_website\_hostname) | Fully Qualified Domain Name for website | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_cloudfront_logs_arn"></a> [bucket\_cloudfront\_logs\_arn](#output\_bucket\_cloudfront\_logs\_arn) | CloudFront Standard Logging Bucket ARN |
| <a name="output_bucket_cloudfront_logs_bucket_key_enabled"></a> [bucket\_cloudfront\_logs\_bucket\_key\_enabled](#output\_bucket\_cloudfront\_logs\_bucket\_key\_enabled) | CloudFront Standard Logs Bucket Key Enabled |
| <a name="output_bucket_cloudfront_logs_bucket_sse_algo"></a> [bucket\_cloudfront\_logs\_bucket\_sse\_algo](#output\_bucket\_cloudfront\_logs\_bucket\_sse\_algo) | SSE Algorithm for CloudFront Standard Logs Bucket |
| <a name="output_bucket_cloudfront_logs_bucket_sse_kms_key_id"></a> [bucket\_cloudfront\_logs\_bucket\_sse\_kms\_key\_id](#output\_bucket\_cloudfront\_logs\_bucket\_sse\_kms\_key\_id) | SSE KMS Key ID for CloudFront Standard Logs Bucket |
| <a name="output_bucket_cloudfront_logs_force_destroy"></a> [bucket\_cloudfront\_logs\_force\_destroy](#output\_bucket\_cloudfront\_logs\_force\_destroy) | Is force destroy set for the CloudFront Standard Logging bucket? |
| <a name="output_bucket_cloudfront_logs_id"></a> [bucket\_cloudfront\_logs\_id](#output\_bucket\_cloudfront\_logs\_id) | CloudFront Logging Bucket ID |
| <a name="output_bucket_cloudfront_logs_oac_policy"></a> [bucket\_cloudfront\_logs\_oac\_policy](#output\_bucket\_cloudfront\_logs\_oac\_policy) | CloudFront Origin Access Control |
| <a name="output_bucket_cloudfront_logs_region"></a> [bucket\_cloudfront\_logs\_region](#output\_bucket\_cloudfront\_logs\_region) | CloudFront Standard Logs S3 Bucket Region |
| <a name="output_bucket_cloudfront_logs_versioning_enabled"></a> [bucket\_cloudfront\_logs\_versioning\_enabled](#output\_bucket\_cloudfront\_logs\_versioning\_enabled) | CloudFront Logging Bucket Versioning |
| <a name="output_bucket_cloudfront_logs_versioning_mfa_delete"></a> [bucket\_cloudfront\_logs\_versioning\_mfa\_delete](#output\_bucket\_cloudfront\_logs\_versioning\_mfa\_delete) | CloudFront Logging Bucket Versioning MFA Delete |
| <a name="output_bucket_website_arn"></a> [bucket\_website\_arn](#output\_bucket\_website\_arn) | Static asset S3 Bucket ARN |
| <a name="output_bucket_website_bucket_key_enabled"></a> [bucket\_website\_bucket\_key\_enabled](#output\_bucket\_website\_bucket\_key\_enabled) | Website Bucket Key Enabled |
| <a name="output_bucket_website_bucket_sse_algo"></a> [bucket\_website\_bucket\_sse\_algo](#output\_bucket\_website\_bucket\_sse\_algo) | SSE Algorithm for Website Bucket |
| <a name="output_bucket_website_bucket_sse_kms_key_id"></a> [bucket\_website\_bucket\_sse\_kms\_key\_id](#output\_bucket\_website\_bucket\_sse\_kms\_key\_id) | SSE KMS Key ID for Website Bucket |
| <a name="output_bucket_website_force_destroy"></a> [bucket\_website\_force\_destroy](#output\_bucket\_website\_force\_destroy) | Is force destroy set for the static asset bucket? |
| <a name="output_bucket_website_id"></a> [bucket\_website\_id](#output\_bucket\_website\_id) | Static asset Bucket ID |
| <a name="output_bucket_website_region"></a> [bucket\_website\_region](#output\_bucket\_website\_region) | Static asset Bucket Region |
| <a name="output_bucket_website_versioning_enabled"></a> [bucket\_website\_versioning\_enabled](#output\_bucket\_website\_versioning\_enabled) | Static asset Bucket Versioning |
| <a name="output_bucket_website_versioning_mfa_delete"></a> [bucket\_website\_versioning\_mfa\_delete](#output\_bucket\_website\_versioning\_mfa\_delete) | Static asset Bucket Versioning MFA Delete |
| <a name="output_certificate_website_arn"></a> [certificate\_website\_arn](#output\_certificate\_website\_arn) | Site Certificate ARN |
| <a name="output_certificate_website_domain_name"></a> [certificate\_website\_domain\_name](#output\_certificate\_website\_domain\_name) | Site Certificate domain name |
| <a name="output_certificate_website_domain_validation_name"></a> [certificate\_website\_domain\_validation\_name](#output\_certificate\_website\_domain\_validation\_name) | The resource record name for domain validation. |
| <a name="output_certificate_website_domain_validation_type"></a> [certificate\_website\_domain\_validation\_type](#output\_certificate\_website\_domain\_validation\_type) | The resource record type for domain validation. |
| <a name="output_certificate_website_domain_validation_value"></a> [certificate\_website\_domain\_validation\_value](#output\_certificate\_website\_domain\_validation\_value) | The resource record value for domain validation. |
| <a name="output_certificate_website_expiration"></a> [certificate\_website\_expiration](#output\_certificate\_website\_expiration) | Site Certificate Expiration |
| <a name="output_certificate_website_issued"></a> [certificate\_website\_issued](#output\_certificate\_website\_issued) | Site Certificate Issued |
| <a name="output_certificate_website_status"></a> [certificate\_website\_status](#output\_certificate\_website\_status) | Site Certificate provisioning status |
| <a name="output_cloudfront_cache_policy_id"></a> [cloudfront\_cache\_policy\_id](#output\_cloudfront\_cache\_policy\_id) | CloudFront Cache Policy ID |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | CloudFront Distribution ARN |
| <a name="output_cloudfront_distribution_domain_name"></a> [cloudfront\_distribution\_domain\_name](#output\_cloudfront\_distribution\_domain\_name) | CloudFront Distribution Domain Name |
| <a name="output_cloudfront_distribution_http_last_modified_time"></a> [cloudfront\_distribution\_http\_last\_modified\_time](#output\_cloudfront\_distribution\_http\_last\_modified\_time) | CloudFront Distribution Last Modified |
| <a name="output_cloudfront_distribution_http_version"></a> [cloudfront\_distribution\_http\_version](#output\_cloudfront\_distribution\_http\_version) | CloudFront Distribution HTTP Version |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | CloudFront Distribution ID |
| <a name="output_cloudfront_distribution_status"></a> [cloudfront\_distribution\_status](#output\_cloudfront\_distribution\_status) | CloudFront Distribution Status |
| <a name="output_cloudfront_distribution_zone_id"></a> [cloudfront\_distribution\_zone\_id](#output\_cloudfront\_distribution\_zone\_id) | CloudFront Distribution Zone ID |
| <a name="output_cloudfront_enabled"></a> [cloudfront\_enabled](#output\_cloudfront\_enabled) | CloudFront Enabled |
| <a name="output_cloudfront_logging"></a> [cloudfront\_logging](#output\_cloudfront\_logging) | Is CloudFront logging enabled? |
| <a name="output_cloudfront_logging_prefix"></a> [cloudfront\_logging\_prefix](#output\_cloudfront\_logging\_prefix) | CloudFront Logging Prefix. Can be used in a lifecycle rule filter |
| <a name="output_cloudfront_origin_access_control_id"></a> [cloudfront\_origin\_access\_control\_id](#output\_cloudfront\_origin\_access\_control\_id) | CloudFront Origin Access Control |
| <a name="output_dns_website_record"></a> [dns\_website\_record](#output\_dns\_website\_record) | Website DNS Record Name |
| <a name="output_dns_website_record_target"></a> [dns\_website\_record\_target](#output\_dns\_website\_record\_target) | Website DNS Record Target |
| <a name="output_z_gandi_domain"></a> [z\_gandi\_domain](#output\_z\_gandi\_domain) | True if deployment DNS is using Gandi |
| <a name="output_z_route53_domain"></a> [z\_route53\_domain](#output\_z\_route53\_domain) | True if deployment DNS is using Route 53 |
| <a name="output_z_valid_inputs"></a> [z\_valid\_inputs](#output\_z\_valid\_inputs) | Will be true if all inputs are valid |
| <a name="output_z_website_url"></a> [z\_website\_url](#output\_z\_website\_url) | Website URL |
<!-- END_TF_DOCS -->
