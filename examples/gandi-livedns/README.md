
<!-- BEGIN_TF_DOCS -->


## Instructions

#### Create Input Variables
 Create `terraform.tfvars` with the required input variables

#### Set the hostname for the website
* `website_hostname`

#### Configure DNS Variables

##### AWS Route 53
* `route53_zone_id`

#### Gandi LiveDNS
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

### Upload Static Assets
Upload static assets to S3 bucket.

This module does not sync static assets for you.
There is an example script included that will do so, but it's assumed that you'll
work out deploying the static assets independent of this module.

#### Use include example script
* It will determine the static asset bucket name and CloudFront
distribution from the terraform output.
* If `website_bucket_versioning` is disabled, it will also invalidate CloudFront cache.

From one of the example directories:

```shell
$ ../../example-files/bin/deploy-site.sh -s htdocs
````
## Check Input Validation
The module will validate the input variables and set a boolean `z-valid-inputs`.

It will catch some errors that variable validation alone will not catch.

You can check the output of `z-valid-inputs` as part of your plan by checking its status.

```shell
#!/usr/bin/env bash
if [[ $(terraform plan -var-file terraform.tfvars -out tfplan.out -no-color  |grep z-valid-inputs |awk '{print $4}') == "true" ]];then
echo "VALID INPUTS"
else
echo "INVALID INPUTS"
fi
```

or making a one-liner:
```shell
if [[ $(terraform plan -var-file terraform.tfvars -out tfplan.out -no-color  |grep z-valid-inputs |awk '{print $4}') == "true" ]];then echo "VALID INPUTS"; else echo "INVALID INPUTS"; fi
```

Alternatively, you can combine the plan and apply steps based on the output of `z-valid-inputs`:
```shell
if [[ $(terraform plan -var-file terraform.tfvars -out tfplan.out -no-color  |grep z-valid-inputs |awk '{print $4}') == "true" ]];then echo "VALID INPUTS"; terraform apply tfplan.out; else echo "INVALID INPUTS"; fi
```

## Example
### Gandi LiveDNS Minimal Example
This is the bare minimum configuration need to deploy a website using Gandi
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

# Minimal Gandi LiveDNS configuration. See README.me for more detailed example.
module "site" {
  source           = "git::git@github.com:garyrule/terraform-aws-static-website.git?ref=v0.0.2"
  dns_type         = "gandi"
  gandi_key        = var.gandi_key
  website_hostname = var.website_hostname
}
```

### Gandi LiveDNS Full Example
Not every option is passed but this will provide an example of a full configuration.
### Gandi LiveDNS
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
  source           = "git::git@github.com:garyrule/terraform-aws-static-website.git?ref=v0.0.2"
  dns_type         = "gandi"
  gandi_key        = var.gandi_key
  website_hostname = var.website_hostname
  region           = "us-west-1"

  # CloudFront
  cloudfront_enabled = true

  # Cache
  cloudfront_cache_max_ttl                      = 3600
  cloudfront_cache_min_ttl                      = 0
  cloudfront_cache_default_ttl                  = 600
  cloudfront_cache_allowed_methods              = ["GET", "HEAD", "OPTIONS"]
  cloudfront_cached_methods                     = ["GET", "HEAD", "OPTIONS"]
  cloudfront_cache_compress                     = true
  cloudfront_cache_policy_cookie_behavior       = "none"
  cloudfront_cache_policy_header_behavior       = "none"
  cloudfront_cache_policy_query_string_behavior = "none"

  # Geo restrictions
  cloudfront_geo_restriction_type = "whitelist"
  cloudfront_geo_restriction_locations = [
    "US", "MX", "CA", "GB", "DE", "FR",
    "ES", "IT", "JP", "SG", "AU", "NZ"
  ]

  # Logging
  cloudfront_logging         = false
  cloudfront_logging_cookies = false

  # Deployment settings
  cloudfront_price_class            = "PriceClass_100"
  cloudfront_maximum_http_version   = "http2and3"
  cloudfront_viewer_security_policy = "TLSv1.2_2021"

  # S3
  bucket_website_versioning    = false
  bucket_website_key_enabled   = false
  bucket_website_force_destroy = true
  bucket_website_sse_algo      = "AES256"

  bucket_cloudfront_logs_versioning    = false
  bucket_cloudfront_logs_force_destroy = true
  bucket_cloudfront_logs_key_enabled   = false
  bucket_cloudfront_logs_sse_algo      = "AES256"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gandi_key"></a> [gandi\_key](#input\_gandi\_key) | Gandi API Key | `string` | n/a | yes |
| <a name="input_website_hostname"></a> [website\_hostname](#input\_website\_hostname) | Fully Qualified Domain Name for website | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket-cloudfront-logs-arn"></a> [bucket-cloudfront-logs-arn](#output\_bucket-cloudfront-logs-arn) | CLoudFront Standard Loggiing Bucket ARN |
| <a name="output_bucket-cloudfront-logs-bucket-key-enabled"></a> [bucket-cloudfront-logs-bucket-key-enabled](#output\_bucket-cloudfront-logs-bucket-key-enabled) | CloudFront Standard Logging Bucket Key Enabled |
| <a name="output_bucket-cloudfront-logs-bucket-sse-algo"></a> [bucket-cloudfront-logs-bucket-sse-algo](#output\_bucket-cloudfront-logs-bucket-sse-algo) | SSE Algorithm for CloudFront Standard Logging Bucket |
| <a name="output_bucket-cloudfront-logs-bucket-sse-kms-key-id"></a> [bucket-cloudfront-logs-bucket-sse-kms-key-id](#output\_bucket-cloudfront-logs-bucket-sse-kms-key-id) | SSE KMS Key ID for CloudFront Standard Logging Bucket |
| <a name="output_bucket-cloudfront-logs-force-destroy"></a> [bucket-cloudfront-logs-force-destroy](#output\_bucket-cloudfront-logs-force-destroy) | Is force destroy set for the CloudFront Standard Logging bucket? |
| <a name="output_bucket-cloudfront-logs-id"></a> [bucket-cloudfront-logs-id](#output\_bucket-cloudfront-logs-id) | CloudFront Logging Bucket ID |
| <a name="output_bucket-cloudfront-logs-oac-policy"></a> [bucket-cloudfront-logs-oac-policy](#output\_bucket-cloudfront-logs-oac-policy) | CloudFront Origin Access Control |
| <a name="output_bucket-cloudfront-logs-versioning-enabled"></a> [bucket-cloudfront-logs-versioning-enabled](#output\_bucket-cloudfront-logs-versioning-enabled) | CloudFront Logging Bucket Versioning |
| <a name="output_bucket-cloudfront-logs-versioning-mfa-delete"></a> [bucket-cloudfront-logs-versioning-mfa-delete](#output\_bucket-cloudfront-logs-versioning-mfa-delete) | CloudFront Logging Bucket Versioning MFA Delete |
| <a name="output_bucket-website-arn"></a> [bucket-website-arn](#output\_bucket-website-arn) | Static asset S3 Bucket ARN |
| <a name="output_bucket-website-force-destroy"></a> [bucket-website-force-destroy](#output\_bucket-website-force-destroy) | Is force destroy set for the static asset bucket? |
| <a name="output_bucket-website-id"></a> [bucket-website-id](#output\_bucket-website-id) | Static asset Bucket ID |
| <a name="output_bucket-website-region"></a> [bucket-website-region](#output\_bucket-website-region) | Static asset Bucket Region |
| <a name="output_bucket-website-versioning-enabled"></a> [bucket-website-versioning-enabled](#output\_bucket-website-versioning-enabled) | Static asset Bucket Versioning |
| <a name="output_bucket-website-versioning-mfa-delete"></a> [bucket-website-versioning-mfa-delete](#output\_bucket-website-versioning-mfa-delete) | Static asset Bucket Versioning MFA Delete |
| <a name="output_certificate-website-arn"></a> [certificate-website-arn](#output\_certificate-website-arn) | Site Certificate ARN |
| <a name="output_certificate-website-domain-name"></a> [certificate-website-domain-name](#output\_certificate-website-domain-name) | Site Certificate domain name |
| <a name="output_certificate-website-domain-validation-name"></a> [certificate-website-domain-validation-name](#output\_certificate-website-domain-validation-name) | The resource record name for domain validation. |
| <a name="output_certificate-website-domain-validation-type"></a> [certificate-website-domain-validation-type](#output\_certificate-website-domain-validation-type) | The resource record type for domain validation. |
| <a name="output_certificate-website-domain-validation-value"></a> [certificate-website-domain-validation-value](#output\_certificate-website-domain-validation-value) | The resource record value for domain validation. |
| <a name="output_certificate-website-expiration"></a> [certificate-website-expiration](#output\_certificate-website-expiration) | Site Certificate Expiration |
| <a name="output_certificate-website-issued"></a> [certificate-website-issued](#output\_certificate-website-issued) | Site Certificate Issued |
| <a name="output_certificate-website-status"></a> [certificate-website-status](#output\_certificate-website-status) | Site Certificate provisioning status |
| <a name="output_cloudfront-distribution-arn"></a> [cloudfront-distribution-arn](#output\_cloudfront-distribution-arn) | CloudFront Distribution ARN |
| <a name="output_cloudfront-distribution-domain-name"></a> [cloudfront-distribution-domain-name](#output\_cloudfront-distribution-domain-name) | CloudFront Distribution Domain Name |
| <a name="output_cloudfront-distribution-http-last-modified-time"></a> [cloudfront-distribution-http-last-modified-time](#output\_cloudfront-distribution-http-last-modified-time) | CloudFront Distribution Last Modified |
| <a name="output_cloudfront-distribution-http-version"></a> [cloudfront-distribution-http-version](#output\_cloudfront-distribution-http-version) | CloudFront Distribution HTTP Version |
| <a name="output_cloudfront-distribution-id"></a> [cloudfront-distribution-id](#output\_cloudfront-distribution-id) | CloudFront Distribution ID |
| <a name="output_cloudfront-distribution-status"></a> [cloudfront-distribution-status](#output\_cloudfront-distribution-status) | CloudFront Distribution Status |
| <a name="output_cloudfront-distribution-zone-id"></a> [cloudfront-distribution-zone-id](#output\_cloudfront-distribution-zone-id) | CloudFront Distribution Zone ID |
| <a name="output_cloudfront-enabled"></a> [cloudfront-enabled](#output\_cloudfront-enabled) | CloudFront Enabled |
| <a name="output_cloudfront-origin-access-control-id"></a> [cloudfront-origin-access-control-id](#output\_cloudfront-origin-access-control-id) | CloudFront Origin Access Control |
| <a name="output_cloudfront_logging"></a> [cloudfront\_logging](#output\_cloudfront\_logging) | Is CloudFront logging enabled? |
| <a name="output_website-dns-record"></a> [website-dns-record](#output\_website-dns-record) | Website DNS Record Name |
| <a name="output_website-domain-resource-id"></a> [website-domain-resource-id](#output\_website-domain-resource-id) | Website DNS Record ID |
| <a name="output_website-domain-target"></a> [website-domain-target](#output\_website-domain-target) | Website DNS Record Target |
| <a name="output_z-is-gandi-domain"></a> [z-is-gandi-domain](#output\_z-is-gandi-domain) | True if deployment DNS is using Gandi |
| <a name="output_z-is-route53-domain"></a> [z-is-route53-domain](#output\_z-is-route53-domain) | True if deployment DNS is using Route 53 |
| <a name="output_z-valid-inputs"></a> [z-valid-inputs](#output\_z-valid-inputs) | Will be true if all inputs are valid |
| <a name="output_z-website-url"></a> [z-website-url](#output\_z-website-url) | Website URL |
<!-- END_TF_DOCS -->
