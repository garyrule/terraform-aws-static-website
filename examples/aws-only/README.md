## Instructions
The module will configure a static website with Route53.

### Create Input Variables
* Create `terraform.tfvars` with input variables
  * `website_hostname`
  * `route53_zone_id`

### Initialize Project
* `terraform init`
* `terraform plan -var-file terraform.tfvars -out tfplan.out`
* `terraform apply`

### Upload Static Files
```shell
$ ../bin/deploy-site.sh -s htdocs
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_site"></a> [site](#module\_site) | git::git@github.com:garyrule/tf_static_web.git | master |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Zone ID of Route53 Zone that we are using to host this website | `string` | n/a | yes |
| <a name="input_website_hostname"></a> [website\_hostname](#input\_website\_hostname) | Fully Qualified Domain Name for website | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket-endpoint"></a> [bucket-endpoint](#output\_bucket-endpoint) | Static file Bucket Website Endpoint |
| <a name="output_bucket-hosted-zone-id"></a> [bucket-hosted-zone-id](#output\_bucket-hosted-zone-id) | Static file Bucket Zone ID |
| <a name="output_bucket-id"></a> [bucket-id](#output\_bucket-id) | Static file Bucket ID |
| <a name="output_bucket-region"></a> [bucket-region](#output\_bucket-region) | Static file Bucket Region |
| <a name="output_bucket-versioning"></a> [bucket-versioning](#output\_bucket-versioning) | Static file Bucket Versioning |
| <a name="output_certificate-validation-domain-name"></a> [certificate-validation-domain-name](#output\_certificate-validation-domain-name) | Certificate Validation, validation record FQDNs |
| <a name="output_cloudfront-distribution-domain-name"></a> [cloudfront-distribution-domain-name](#output\_cloudfront-distribution-domain-name) | Cloudfront Distribution Domain Name |
| <a name="output_cloudfront-distribution-http-last-modified-time"></a> [cloudfront-distribution-http-last-modified-time](#output\_cloudfront-distribution-http-last-modified-time) | Cloudfront Distribution Last Modified |
| <a name="output_cloudfront-distribution-http-version"></a> [cloudfront-distribution-http-version](#output\_cloudfront-distribution-http-version) | Cloudfront Distribution HTTP Version |
| <a name="output_cloudfront-distribution-id"></a> [cloudfront-distribution-id](#output\_cloudfront-distribution-id) | Cloudfront Distribution ID |
| <a name="output_cloudfront-distribution-status"></a> [cloudfront-distribution-status](#output\_cloudfront-distribution-status) | Cloudfront Distribution Status |
| <a name="output_cloudfront-distribution-zone-id"></a> [cloudfront-distribution-zone-id](#output\_cloudfront-distribution-zone-id) | Cloudfront Distribution Zone ID |
| <a name="output_dns-site-alias"></a> [dns-site-alias](#output\_dns-site-alias) | DNS Site Alias |
| <a name="output_dns-site-id"></a> [dns-site-id](#output\_dns-site-id) | DNS Site ID |
| <a name="output_dns-site-name"></a> [dns-site-name](#output\_dns-site-name) | DNS Site Name |
| <a name="output_referer_header_value"></a> [referer\_header\_value](#output\_referer\_header\_value) | Referer header value Cloudfront passes to the S3 bucket |
| <a name="output_site-certificate-arn"></a> [site-certificate-arn](#output\_site-certificate-arn) | Site Certificate ARN |
| <a name="output_site-certificate-domain-name"></a> [site-certificate-domain-name](#output\_site-certificate-domain-name) | Site Certificate domain name |
| <a name="output_site-certificate-domain-validation-options"></a> [site-certificate-domain-validation-options](#output\_site-certificate-domain-validation-options) | Site Certificate Domain Validation Options |
| <a name="output_site-certificate-expiration"></a> [site-certificate-expiration](#output\_site-certificate-expiration) | Site Certificate Expiration |
| <a name="output_site-certificate-issued"></a> [site-certificate-issued](#output\_site-certificate-issued) | Site Certificate Issued |
| <a name="output_site-certificate-status"></a> [site-certificate-status](#output\_site-certificate-status) | Site Certificate provisioning status |
| <a name="output_z-is-gandi-domain"></a> [z-is-gandi-domain](#output\_z-is-gandi-domain) | n/a |
| <a name="output_z-is-route53-domain"></a> [z-is-route53-domain](#output\_z-is-route53-domain) | n/a |
<!-- END_TF_DOCS -->
