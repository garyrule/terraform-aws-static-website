## Instructions
The module will configure a static website with Route 53.

### Create Input Variables
* Create `terraform.tfvars` with input variables
  * `website_hostname`
  * `route53_zone_id`

### Edit main.tf - Optional
Edit `main.tf` and make any changes.

### Initialize Project
* `terraform init`
* `terraform plan -var-file terraform.tfvars -out tfplan.out`
* `terraform apply`

### Upload Static Files
```shell
$ ../bin/deploy-site.sh -s htdocs
```

<!-- BEGIN_TF_DOCS -->


## Example using AWS Route 53
```hcl
terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }
  }
}

## Example All-AWS w/ mimimum inputs
module "site" {
  source           = "git::git@github.com:garyrule/terraform-aws-static-website.git?ref=master"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
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
| <a name="output_bucket-hosted-zone-id"></a> [bucket-hosted-zone-id](#output\_bucket-hosted-zone-id) | Static file Bucket Zone ID |
| <a name="output_bucket-id"></a> [bucket-id](#output\_bucket-id) | Static file Bucket ID |
| <a name="output_bucket-region"></a> [bucket-region](#output\_bucket-region) | Static file Bucket Region |
| <a name="output_bucket-versioning"></a> [bucket-versioning](#output\_bucket-versioning) | Static file Bucket Versioning |
| <a name="output_certificate-validation-domain-name"></a> [certificate-validation-domain-name](#output\_certificate-validation-domain-name) | Certificate Validation, validation record FQDNs |
| <a name="output_cloudfront-distribution-domain-name"></a> [cloudfront-distribution-domain-name](#output\_cloudfront-distribution-domain-name) | CloudFront Distribution Domain Name |
| <a name="output_cloudfront-distribution-http-last-modified-time"></a> [cloudfront-distribution-http-last-modified-time](#output\_cloudfront-distribution-http-last-modified-time) | CloudFront Distribution Last Modified |
| <a name="output_cloudfront-distribution-http-version"></a> [cloudfront-distribution-http-version](#output\_cloudfront-distribution-http-version) | CloudFront Distribution HTTP Version |
| <a name="output_cloudfront-distribution-id"></a> [cloudfront-distribution-id](#output\_cloudfront-distribution-id) | CloudFront Distribution ID |
| <a name="output_cloudfront-distribution-status"></a> [cloudfront-distribution-status](#output\_cloudfront-distribution-status) | CloudFront Distribution Status |
| <a name="output_cloudfront-distribution-zone-id"></a> [cloudfront-distribution-zone-id](#output\_cloudfront-distribution-zone-id) | CloudFront Distribution Zone ID |
| <a name="output_dns-site-alias"></a> [dns-site-alias](#output\_dns-site-alias) | DNS Site Alias |
| <a name="output_dns-site-id"></a> [dns-site-id](#output\_dns-site-id) | DNS Site ID |
| <a name="output_dns-site-name"></a> [dns-site-name](#output\_dns-site-name) | DNS Site Name |
| <a name="output_site-certificate-arn"></a> [site-certificate-arn](#output\_site-certificate-arn) | Site Certificate ARN |
| <a name="output_site-certificate-domain-name"></a> [site-certificate-domain-name](#output\_site-certificate-domain-name) | Site Certificate domain name |
| <a name="output_site-certificate-domain-validation-options"></a> [site-certificate-domain-validation-options](#output\_site-certificate-domain-validation-options) | Site Certificate Domain Validation Options |
| <a name="output_site-certificate-expiration"></a> [site-certificate-expiration](#output\_site-certificate-expiration) | Site Certificate Expiration |
| <a name="output_site-certificate-issued"></a> [site-certificate-issued](#output\_site-certificate-issued) | Site Certificate Issued |
| <a name="output_site-certificate-status"></a> [site-certificate-status](#output\_site-certificate-status) | Site Certificate provisioning status |
| <a name="output_z-is-gandi-domain"></a> [z-is-gandi-domain](#output\_z-is-gandi-domain) | True if deployment DNS is using Gandi |
| <a name="output_z-is-route53-domain"></a> [z-is-route53-domain](#output\_z-is-route53-domain) | True if deployment DNS is using Route 53 |
<!-- END_TF_DOCS -->
