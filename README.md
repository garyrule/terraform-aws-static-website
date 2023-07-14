# terraform-aws-static-website
**Deploy secure, cost-effective static websites using CloudFront, S3, ACM and Route 53.**

With support for using [Gandi](https://www.gandi.net) LiveDNS.

![terraform-aws-static-website](https://github.com/garyrule/terraform-aws-static-website/blob/bb572caa8fce31fed41f5e630e182385373be1e3/img/dia.jpeg)

## Features
* Option to use either Route 53 (default) or Gandi LiveDNS.
* Configurable CloudFront distribution to cache and serve static assets.
  * CloudFront [Standard Log](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html) delivery to a private s3 bucket, enabled by default.
    * Log cookies with `cloudfront_logging_cookies`, disabled by default
    * Choose log prefix `cloudfront_logging_prefix`, default is the website hostname wth dashes. e.g. `static-yourdomain-com/`
  * Cache behavior for static assets is configurable using a [CloudFront Cache Policy](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-the-cache-key.html#cache-key-create-cache-policy).
    * See `cloudfront_cache_*` inputs for more details.
  * [Geo restrictions](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html) for CloudFront distribution, disabled by default.
  * Set maximum http version for CloudFront distribution with `cloudfront_maximum_http_version`.
  * Choose [Security Policy](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html) with `cloudfront_viewer_security_policy`.
  * Select [Price Class](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html) with `cloudfront_price_class`.
  * Ability to select the ["Dedicated IP Custom SSL"](https://aws.amazon.com/cloudfront/pricing/) feature with `cloudfront_viewer_ssl_support_method`
* Configurable private s3 buckets for static assets and CloudFront log delivery.
  * Versioning for static assets, enabled by default.
  * Versioning for CloudFront logs, disabled by default.
  * Access to static assets granted to CloudFront via [Origin Access Control (OAC)](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html).
    * Default policy allows `s3:GetObject`, `s3:GetObjectVersion` and `s3:ListBucket` to static asset bucket.
    * Create and pass [your own IAM policy](doc/BUCKET_POLICY.md) to customize CloudFront access to S3.
  * [Bucket Keys enabled by default](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html)
  * [Server Side Encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html) using either S3 managed keys (default) or with AWS Key Management Service.
    * To choose KMS see: `bucket_website_sse_algo` and `bucket_cloudfront_logs_sse_algo`
    * To specify a KMS key see: `bucket_website_sse_kms_key_id` and `bucket_cloudfront_logs_kms_key_id`.
* Support for [gandi_sharing_id](https://aws.amazon.com/cloudfront/pricing/)


## Components
| Function                                 | Service                                                                                                |
|------------------------------------------|--------------------------------------------------------------------------------------------------------|
| Static Asset Storage and CloudFront Logs | [S3](https://aws.amazon.com/s3/)                                                                       |
| SSL Certificate                          | [ACM](https://aws.amazon.com/certificate-manager/)                                                     |
| DNS                                      | [Route 53](https://aws.amazon.com/route53/) or [Gandi LiveDNS](https://www.gandi.net/en-US/domain/dns) |
| CDN                                      | [CloudFront](https://aws.amazon.com/cloudfront/)                                                                                         |



## Examples
[Example directories](./examples/) include a minimal configuration in `main.tf`.
The README.md file for eache example shows a more detailed
configuration example.

<!-- BEGIN_TF_DOCS -->
# terraform-docs
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.8.0 |
| <a name="requirement_gandi"></a> [gandi](#requirement\_gandi) | = 2.2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.8.0 |
| <a name="provider_aws.use1"></a> [aws.use1](#provider\_aws.use1) | 5.8.0 |
| <a name="provider_gandi"></a> [gandi](#provider\_gandi) | 2.2.3 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.site-aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_acm_certificate_validation.site-gandi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_cache_policy.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_route53_record.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.site-validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [gandi_livedns_record.site](https://registry.terraform.io/providers/go-gandi/gandi/2.2.3/docs/resources/livedns_record) | resource |
| [gandi_livedns_record.site-validation](https://registry.terraform.io/providers/go-gandi/gandi/2.2.3/docs/resources/livedns_record) | resource |
| [aws_iam_policy_document.cloudfront_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_website_hostname"></a> [website\_hostname](#input\_website\_hostname) | Fully qualified domain name for website - `static.yourdomain.com` | `string` | n/a | yes |
| <a name="input_bucket_cloudfront_logs_force_destroy"></a> [bucket\_cloudfront\_logs\_force\_destroy](#input\_bucket\_cloudfront\_logs\_force\_destroy) | Force Destroy S3 Bucket? | `bool` | `false` | no |
| <a name="input_bucket_cloudfront_logs_key_enabled"></a> [bucket\_cloudfront\_logs\_key\_enabled](#input\_bucket\_cloudfront\_logs\_key\_enabled) | S3 Bucket Key Enabled for CloudFront logs<br>  See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html | `bool` | `true` | no |
| <a name="input_bucket_cloudfront_logs_sse_algo"></a> [bucket\_cloudfront\_logs\_sse\_algo](#input\_bucket\_cloudfront\_logs\_sse\_algo) | Website Bucket SSE Algorithm for CloudFront logs<br>    See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/specifying-kms-encryption.html | `string` | `"AES256"` | no |
| <a name="input_bucket_cloudfront_logs_sse_kms_key_id"></a> [bucket\_cloudfront\_logs\_sse\_kms\_key\_id](#input\_bucket\_cloudfront\_logs\_sse\_kms\_key\_id) | Website Bucket SSE KMS Key ID for CloudFront logs<br>    See Here: https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/s3_bucket_server_side_encryption_configuration#kms_master_key_id | `string` | `""` | no |
| <a name="input_bucket_cloudfront_logs_versioning"></a> [bucket\_cloudfront\_logs\_versioning](#input\_bucket\_cloudfront\_logs\_versioning) | S3 Bucket Versioning for CloudFront logs | `bool` | `false` | no |
| <a name="input_bucket_website_force_destroy"></a> [bucket\_website\_force\_destroy](#input\_bucket\_website\_force\_destroy) | Force Destroy S3 Bucket? | `bool` | `false` | no |
| <a name="input_bucket_website_key_enabled"></a> [bucket\_website\_key\_enabled](#input\_bucket\_website\_key\_enabled) | S3 Bucket Key Enabled for static assets<br>  See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html | `bool` | `true` | no |
| <a name="input_bucket_website_policy"></a> [bucket\_website\_policy](#input\_bucket\_website\_policy) | JSON representation of your custom S3 Bucket Policy for static assets. See "BUCKET\_POLICY.md" in doc/ | `string` | `""` | no |
| <a name="input_bucket_website_sse_algo"></a> [bucket\_website\_sse\_algo](#input\_bucket\_website\_sse\_algo) | Website Bucket SSE Algorithm for static assets<br>    See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/specifying-kms-encryption.html | `string` | `"AES256"` | no |
| <a name="input_bucket_website_sse_kms_key_id"></a> [bucket\_website\_sse\_kms\_key\_id](#input\_bucket\_website\_sse\_kms\_key\_id) | Website Bucket SSE KMS Key ID for static assets<br>    See Here: https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/s3_bucket_server_side_encryption_configuration#kms_master_key_id | `string` | `""` | no |
| <a name="input_bucket_website_versioning"></a> [bucket\_website\_versioning](#input\_bucket\_website\_versioning) | S3 Bucket Versioning for static assets | `bool` | `true` | no |
| <a name="input_cloudfront_cache_allowed_methods"></a> [cloudfront\_cache\_allowed\_methods](#input\_cloudfront\_cache\_allowed\_methods) | CloudFront Allowed Cache Methods -<br>  Controls which HTTP methods CloudFront processes and forwards to your Amazon<br>  S3 bucket or your custom origin. | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cloudfront_cache_compress"></a> [cloudfront\_cache\_compress](#input\_cloudfront\_cache\_compress) | Whether you want CloudFront to automatically compress content for web<br>  requests that include `Accept-Encoding: gzip` in the request header | `bool` | `true` | no |
| <a name="input_cloudfront_cache_default_ttl"></a> [cloudfront\_cache\_default\_ttl](#input\_cloudfront\_cache\_default\_ttl) | CloudFront Default TTL -<br>  Default amount of time (in seconds) that an object is in a CloudFront cache<br>  before CloudFront forwards another request in the absence of an Cache-Control<br>  max-age or Expires header. | `number` | `3600` | no |
| <a name="input_cloudfront_cache_max_ttl"></a> [cloudfront\_cache\_max\_ttl](#input\_cloudfront\_cache\_max\_ttl) | Specify the maximum amount of time, in seconds, that you want objects to stay<br>  in CloudFront caches before CloudFront queries your origin to see whether the<br>  object has been updated. The value that you specify for Maximum TTL applies<br>  only when your origin adds HTTP headers such as `Cache-Control max-age`,<br>  `Cache-Control s-maxage`, or `Expires` to objects. | `number` | `86400` | no |
| <a name="input_cloudfront_cache_min_ttl"></a> [cloudfront\_cache\_min\_ttl](#input\_cloudfront\_cache\_min\_ttl) | Specify the minimum amount of time, in seconds, that you want objects to stay<br>  in the CloudFront cache before CloudFront sends another request to the origin<br>  to determine whether the object has been updated. | `number` | `0` | no |
| <a name="input_cloudfront_cache_policy_cookie_behavior"></a> [cloudfront\_cache\_policy\_cookie\_behavior](#input\_cloudfront\_cache\_policy\_cookie\_behavior) | Whether any cookies in viewer requests are included in the cache key and<br>  automatically included in requests that CloudFront sends to the origin.<br>  Valid values for cookie\_behavior are `none`, `whitelist`, `allExcept`, and<br>  `all`. | `string` | `"none"` | no |
| <a name="input_cloudfront_cache_policy_cookies"></a> [cloudfront\_cache\_policy\_cookies](#input\_cloudfront\_cache\_policy\_cookies) | List of cookie names used by cloudfront\_cache\_policy\_cookie\_behavior | `list(string)` | `[]` | no |
| <a name="input_cloudfront_cache_policy_header_behavior"></a> [cloudfront\_cache\_policy\_header\_behavior](#input\_cloudfront\_cache\_policy\_header\_behavior) | Whether any HTTP headers are included in the cache key and automatically<br>  included in requests that CloudFront sends to the origin. Valid values for<br>  header\_behavior are `none` and `whitelist`. | `string` | `"none"` | no |
| <a name="input_cloudfront_cache_policy_headers"></a> [cloudfront\_cache\_policy\_headers](#input\_cloudfront\_cache\_policy\_headers) | List of header names used by cloudfront\_cache\_policy\_header\_behavior | `list(string)` | `[]` | no |
| <a name="input_cloudfront_cache_policy_query_string_behavior"></a> [cloudfront\_cache\_policy\_query\_string\_behavior](#input\_cloudfront\_cache\_policy\_query\_string\_behavior) | Whether URL query strings in viewer requests are included in the cache key<br>  and automatically included in requests that CloudFront sends to the origin.<br>  Valid values for query\_string\_behavior are `none`, `whitelist`, `allExcept`,<br>  and `all`. | `string` | `"none"` | no |
| <a name="input_cloudfront_cache_policy_query_strings"></a> [cloudfront\_cache\_policy\_query\_strings](#input\_cloudfront\_cache\_policy\_query\_strings) | List of query string names used by<br>  cloudfront\_cache\_policy\_query\_string\_behavior | `list(string)` | `[]` | no |
| <a name="input_cloudfront_cached_methods"></a> [cloudfront\_cached\_methods](#input\_cloudfront\_cached\_methods) | CloudFront Cached Methods -<br>  Controls whether CloudFront caches the response to requests using the<br>  specified HTTP methods. | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cloudfront_enabled"></a> [cloudfront\_enabled](#input\_cloudfront\_enabled) | Enable the Cloudfront Distribution? | `bool` | `true` | no |
| <a name="input_cloudfront_geo_restriction_locations"></a> [cloudfront\_geo\_restriction\_locations](#input\_cloudfront\_geo\_restriction\_locations) | ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute<br>  your content (whitelist) or not distribute your content (blacklist).<br>  See https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 for a list of codes. | `list(string)` | `[]` | no |
| <a name="input_cloudfront_geo_restriction_type"></a> [cloudfront\_geo\_restriction\_type](#input\_cloudfront\_geo\_restriction\_type) | Method that you want to use to restrict distribution of your content by<br>  country: `none`, `whitelist`, or `blacklist`. | `string` | `"none"` | no |
| <a name="input_cloudfront_logging"></a> [cloudfront\_logging](#input\_cloudfront\_logging) | Whether CloudFront logs requests. | `bool` | `true` | no |
| <a name="input_cloudfront_logging_cookies"></a> [cloudfront\_logging\_cookies](#input\_cloudfront\_logging\_cookies) | Whether CloudFront logs cookies. | `bool` | `false` | no |
| <a name="input_cloudfront_logging_prefix"></a> [cloudfront\_logging\_prefix](#input\_cloudfront\_logging\_prefix) | Logging prefix for CloudFront logs. If you don't specify a prefix, the<br>  prefix will be the website hostname with dashes instead of dots. | `string` | `""` | no |
| <a name="input_cloudfront_maximum_http_version"></a> [cloudfront\_maximum\_http\_version](#input\_cloudfront\_maximum\_http\_version) | Maximum HTTP version to support on the distribution. Allowed values are<br>  `http1.1`, `http2`, `http2and3`, `http3`. | `string` | `"http2"` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | Which CloudFront Price Class to use. Consult this table:<br>  https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html | `string` | `"PriceClass_100"` | no |
| <a name="input_cloudfront_viewer_security_policy"></a> [cloudfront\_viewer\_security\_policy](#input\_cloudfront\_viewer\_security\_policy) | Which Security Policy to use. Consult this table:<br>  https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_cloudfront_viewer_ssl_support_method"></a> [cloudfront\_viewer\_ssl\_support\_method](#input\_cloudfront\_viewer\_ssl\_support\_method) | Which SSL support method to use. `sni-only` or `vip` supported<br><br>  **PLEASE NOTE:** that setting this value to `vip` will incur **significant<br>  additional charges**.<br><br>  Please read this prior to setting this value to `vip`:<br>  https://aws.amazon.com/cloudfront/pricing/ | `string` | `"sni-only"` | no |
| <a name="input_dns_type"></a> [dns\_type](#input\_dns\_type) | Either `aws` or `gandi` depending on where your DNS Zone is hosted | `string` | `"aws"` | no |
| <a name="input_gandi_key"></a> [gandi\_key](#input\_gandi\_key) | Gandi API Key - Required if using Gandi for DNS | `string` | `""` | no |
| <a name="input_gandi_sharing_id"></a> [gandi\_sharing\_id](#input\_gandi\_sharing\_id) | Gandi API Sharing ID - Optional<br>  See:  https://api.gandi.net/docs/reference/#Sharing-ID | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to use for S3 Buckets | `string` | `"us-west-2"` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route 53 Zone ID for website TLD | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket-cloudfront-logs-arn"></a> [bucket-cloudfront-logs-arn](#output\_bucket-cloudfront-logs-arn) | CLoudFront Standard Loggiing Bucket ARN |
| <a name="output_bucket-cloudfront-logs-bucket-key-enabled"></a> [bucket-cloudfront-logs-bucket-key-enabled](#output\_bucket-cloudfront-logs-bucket-key-enabled) | CloudFront Standard Logging Bucket Key Enabled |
| <a name="output_bucket-cloudfront-logs-bucket-sse-algo"></a> [bucket-cloudfront-logs-bucket-sse-algo](#output\_bucket-cloudfront-logs-bucket-sse-algo) | SSE Algorithm for CloudFront Standard Logging Bucket |
| <a name="output_bucket-cloudfront-logs-bucket-sse-kms-key-id"></a> [bucket-cloudfront-logs-bucket-sse-kms-key-id](#output\_bucket-cloudfront-logs-bucket-sse-kms-key-id) | SSE KMS Key ID for CloudFront Standard Logging Bucket |
| <a name="output_bucket-cloudfront-logs-force-destroy"></a> [bucket-cloudfront-logs-force-destroy](#output\_bucket-cloudfront-logs-force-destroy) | Is force destroy set for the CloudFront Standard Logging bucket? |
| <a name="output_bucket-cloudfront-logs-id"></a> [bucket-cloudfront-logs-id](#output\_bucket-cloudfront-logs-id) | CloudFront Standard Logging Bucket ID |
| <a name="output_bucket-cloudfront-logs-oac-policy"></a> [bucket-cloudfront-logs-oac-policy](#output\_bucket-cloudfront-logs-oac-policy) | CloudFront Origin Access Control |
| <a name="output_bucket-cloudfront-logs-versioning-enabled"></a> [bucket-cloudfront-logs-versioning-enabled](#output\_bucket-cloudfront-logs-versioning-enabled) | Whether versioning is enabled on the CloudFront logs bucket |
| <a name="output_bucket-cloudfront-logs-versioning-mfa-delete"></a> [bucket-cloudfront-logs-versioning-mfa-delete](#output\_bucket-cloudfront-logs-versioning-mfa-delete) | Whether MFA delete is enabled on the CloudFront logs bucket |
| <a name="output_bucket-website-arn"></a> [bucket-website-arn](#output\_bucket-website-arn) | Static asset S3 Bucket ARN |
| <a name="output_bucket-website-force-destroy"></a> [bucket-website-force-destroy](#output\_bucket-website-force-destroy) | Is force destroy set for the static asset bucket? |
| <a name="output_bucket-website-id"></a> [bucket-website-id](#output\_bucket-website-id) | Static asset S3 Bucket ID |
| <a name="output_bucket-website-region"></a> [bucket-website-region](#output\_bucket-website-region) | Static asset S3 Bucket Region |
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
| <a name="output_cloudfront-enabled"></a> [cloudfront-enabled](#output\_cloudfront-enabled) | Boolean to determine if CloudFront is enabled |
| <a name="output_cloudfront-origin-access-control-id"></a> [cloudfront-origin-access-control-id](#output\_cloudfront-origin-access-control-id) | CloudFront Origin Access Control |
| <a name="output_cloudfront_logging"></a> [cloudfront\_logging](#output\_cloudfront\_logging) | Is CloudFront logging enabled? |
| <a name="output_gandi-domain"></a> [gandi-domain](#output\_gandi-domain) | Are we a Gandi Domain Boolean |
| <a name="output_website-dns-record"></a> [website-dns-record](#output\_website-dns-record) | Website DNS Record Name |
| <a name="output_website-domain-resource-id"></a> [website-domain-resource-id](#output\_website-domain-resource-id) | Website DNS Record Resource ID |
| <a name="output_website-domain-target"></a> [website-domain-target](#output\_website-domain-target) | Website DNS Record Target |
| <a name="output_z-valid-inputs"></a> [z-valid-inputs](#output\_z-valid-inputs) | Will be true if all inputs are valid |
<!-- END_TF_DOCS -->
