# terraform-aws-static-website
**Deploy secure, cost-effective static websites using CloudFront, S3, ACM and Route 53.**

With support for using [Gandi](https://www.gandi.net) LiveDNS.

![terraform-aws-static-website](https://raw.githubusercontent.com/garyrule/terraform-aws-static-website/55602a8417fd182d758936efeed28365f144b5e4/img/dia.jpeg)
<!-- TOC -->
* [terraform-aws-static-website](#terraform-aws-static-website)
  * [Components](#components)
  * [Prerequisites](#prerequisites)
  * [Feature Overview](#feature-overview)
  * [Examples](#examples)
  * [Configuration Overiew](#configuration-overiew)
    * [CloudFront](#cloudfront)
      * [Logging](#logging)
      * [Cache Behavior](#cache-behavior)
      * [Lambda Function Associations](#lambda-function-associations)
      * [CloudFront Function Association](#cloudfront-function-association)
      * [Geographic Restrictions](#geographic-restrictions)
      * [Security Policy](#security-policy)
      * [Field Level Encryption](#field-level-encryption)
      * [Price Class](#price-class)
      * [Dedicated IP for SSL](#dedicated-ip-for-ssl)
    * [S3](#s3)
      * [Versioning](#versioning)
      * [Access Control](#access-control)
      * [Server Side Encryption](#server-side-encryption)
  * [Requirements](#requirements)
  * [Providers](#providers)
  * [Resources](#resources)
  * [Inputs](#inputs)
  * [Outputs](#outputs)
<!-- TOC -->
## Components
| Function                                         | Service                        |
|--------------------------------------------------|--------------------------------|
| DNS records - Website and certificate validation | [Route 53] or [Gandi LiveDNS]  |
| SSL Certificate                                  | [ACM]                          |
| Content Delivery Network                        | [CloudFront]                   |
| Static Asset Storage and CloudFront Logs         | [S3]                           |

## Prerequisites
* AWS Account and Access Key
  * More details at [Terraform AWS Provider] and [Create AWS Access Key]
* [Download terraform] version >= 1.46

## Feature Overview
* Quickly and easily configure a secure static website.
  * Minimal inputs required to get started
  * Highly configurable S3 and CloudFront distributions to allow for customization.
  * Input validation to reduce errors.
  * Additional input validation and output boolean that can be evaluated by your deployment framework or policy enforcement tools such as [Sentinel].
* Security by default
  * Private encrypted buckets with managed access for CloudFront via [Origin Access Control].
    * Amazon S3 SSE managed keys by default and the ability to use your own KMS keys
  * Default viewer protocol redirects to HTTPS
  * Module defaults to TLSv1.2 and allows TLS protocol v1+ only.
* Cost conscious defaults
  * S3 [Bucket keys] enabled by default which will reduce costs when using a KMS key.
  * Option for customers of Gandi to use their DNS service, which is provided at no extra cost.
  * Static asset bucket has versioning on by default which, when used effectively, can reduce CloudFront cache invalidation costs.
  * CloudFront Price Class set to 100 by default.

## Examples
[Example directories] include a minimal configuration in `main.tf`.
The README.md file for each example shows a more detailed
configuration example.


## Configuration Overiew
### CloudFront
There are a number of input variables that determine the behavior of the CloudFront distribtution.
Please see the [Input] section of this document or the [Example directories] for more details.


#### Logging
[CloudFront Standard Logging] is enabled by default to a separate logging bucket.

The option is provided to disable standard logging and/or enable real-time logging by providing a
real-time logging configuration ARN to the input variable `realtime_log_config_arn`

#### Cache Behavior
The default cache behavior of the CloudFront distribution is managed by a [CloudFront Cache Policy]. The cache policy can be
modified in a number of ways. Please look at the [Input] variables that start with `cloudfront_cache` for descriptions,
options and defaults.

#### Lambda Function Associations
Pass a list of Lambda functions via the [Input] variable: `cloudfront_cache_behavior_lambda_function_associations`

#### CloudFront Function Association
Pass a list of CloudFront Functions via the [Input] variable `cloudfront_cache_behavior_function_associations`

#### Geographic Restrictions
Manage [Geo restrictions], disabled by default, with the `cloudfront_geo_restriction_type` and `cloudfront_geo_restriction_locations` [Input] variables.

#### Security Policy
Choose [Security Policy] with the `cloudfront_viewer_security_policy` [Input] variable.


#### Field Level Encryption
Pass the ID of a Field Level Encryption Configuration via the [Input] variable `cloudfront_field_level_encryption_id`
to enable [Field Level Encryption] for the CloudFront distribution.

#### Price Class
Select an appropriate [Price Class] with the `cloudfront_price_class` [Input] variable.

#### Dedicated IP for SSL
⚠️ **Warning** ⚠️
This option is not required for most use-cases and is relatively 💵 expensive 💵

Ability to select the ["Dedicated IP Custom SSL"] feature with `cloudfront_viewer_ssl_support_method`

### S3
#### Versioning
Enable versioning for static assets (enabled by default) or CloudFront log buckets (disabled by default).

#### Access Control
Access to private static assets bucket granted to CloudFront via [Origin Access Control]
* Default policy allows `s3:GetObject`, `s3:GetObjectVersion` and `s3:ListBucket` to static asset bucket.
* Create and pass [Custom Bucket IAM Policy] to customize CloudFront access to S3.

#### Server Side Encryption
* [Bucket Keys] enabled by default
* [Server Side Encryption] using either S3 managed keys (default) or with AWS Key Management Service.
  * To use your own KMS key
    * Update one or more of the [Input] variables: `bucket_website_sse_algo` and `bucket_cloudfront_logs_sse_algo`
    * Then update one or more of the [Input] variables: `bucket_website_sse_kms_key_id` and `bucket_cloudfront_logs_kms_key_id`



<!-- LINKS -->
[Example directories]:./examples/
[Origin Access Control]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
[Route 53]:https://aws.amazon.com/route53/
[Gandi LiveDNS]:https://www.gandi.net/en-US/domain/dns
[ACM]:https://aws.amazon.com/certificate-manager/
[CloudFront]:https://aws.amazon.com/cloudfront/
[S3]:https://aws.amazon.com/s3/
[gandi_sharing_id]:https://api.gandi.net/docs/reference/#Sharing-ID
[CloudFront Standard Logging]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
[CloudFront Cache Policy]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-the-cache-key.html#cache-key-create-cache-policy
[Geo restrictions]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html
[Security Policy]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html
[Price Class]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html
["Dedicated IP Custom SSL"]:https://aws.amazon.com/cloudfront/pricing/
[Bucket Keys]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
[Server Side Encryption]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html
[Download terraform]:https://www.terraform.io/downloads
[terraform AWS Provider]:https://registry.terraform.io/providers/hashicorp/aws/latest/docs
[Create AWS Access Key]:https://repost.aws/knowledge-center/create-access-key
[Field Level Encryption]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/field-level-encryption.html
[Sentinel]:https://docs.hashicorp.com/sentinel/terraform
[Custom Bucket IAM Policy]:example-files/hcl/aws-bucket-access-policy.tf
[Input]:#inputs



<!-- BEGIN_TF_DOCS -->
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
| <a name="input_bucket_website_policy"></a> [bucket\_website\_policy](#input\_bucket\_website\_policy) | JSON representation of your custom S3 Bucket Policy for static assets.<br>    If blank, the default policy will be used. | `string` | `""` | no |
| <a name="input_bucket_website_sse_algo"></a> [bucket\_website\_sse\_algo](#input\_bucket\_website\_sse\_algo) | Website Bucket SSE Algorithm for static assets<br>    See here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/specifying-kms-encryption.html | `string` | `"AES256"` | no |
| <a name="input_bucket_website_sse_kms_key_id"></a> [bucket\_website\_sse\_kms\_key\_id](#input\_bucket\_website\_sse\_kms\_key\_id) | Website Bucket SSE KMS Key ARN for static assets<br>    See Here: https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/s3_bucket_server_side_encryption_configuration#kms_master_key_id | `string` | `""` | no |
| <a name="input_bucket_website_versioning"></a> [bucket\_website\_versioning](#input\_bucket\_website\_versioning) | S3 Bucket Versioning for static assets | `bool` | `true` | no |
| <a name="input_cloudfront_cache_accept_encoding_brotli"></a> [cloudfront\_cache\_accept\_encoding\_brotli](#input\_cloudfront\_cache\_accept\_encoding\_brotli) | Whether CloudFront caches compressed versions of files in the origin using<br>        the Brotli compression format. | `bool` | `true` | no |
| <a name="input_cloudfront_cache_accept_encoding_gzip"></a> [cloudfront\_cache\_accept\_encoding\_gzip](#input\_cloudfront\_cache\_accept\_encoding\_gzip) | Whether CloudFront caches compressed versions of files in the origin using<br>        the Gzip compression format. | `bool` | `true` | no |
| <a name="input_cloudfront_cache_allowed_methods"></a> [cloudfront\_cache\_allowed\_methods](#input\_cloudfront\_cache\_allowed\_methods) | CloudFront Allowed Cache Methods -<br>    Controls which HTTP methods CloudFront processes and forwards to your Amazon<br>    S3 bucket or your custom origin. | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cloudfront_cache_behavior_function_associations"></a> [cloudfront\_cache\_behavior\_function\_associations](#input\_cloudfront\_cache\_behavior\_function\_associations) | A list of function associations for this cache behavior. | `list(map(string))` | `[]` | no |
| <a name="input_cloudfront_cache_behavior_lambda_function_associations"></a> [cloudfront\_cache\_behavior\_lambda\_function\_associations](#input\_cloudfront\_cache\_behavior\_lambda\_function\_associations) | A list of Lambda function associations for this cache behavior. | `list(map(string))` | `[]` | no |
| <a name="input_cloudfront_cache_behavior_viewer_protocol_policy"></a> [cloudfront\_cache\_behavior\_viewer\_protocol\_policy](#input\_cloudfront\_cache\_behavior\_viewer\_protocol\_policy) | The protocol that viewers can use to access the files in the origin<br>    specified by TargetOriginId when a request matches the path pattern in<br>    PathPattern. Valid values are `allow-all`, `redirect-to-https`, and<br>    `https-only`. | `string` | `"redirect-to-https"` | no |
| <a name="input_cloudfront_cache_compress"></a> [cloudfront\_cache\_compress](#input\_cloudfront\_cache\_compress) | Whether you want CloudFront to automatically compress content for web<br>  requests that include `Accept-Encoding: gzip` in the request header | `bool` | `true` | no |
| <a name="input_cloudfront_cache_default_ttl"></a> [cloudfront\_cache\_default\_ttl](#input\_cloudfront\_cache\_default\_ttl) | CloudFront Default TTL -<br>    Default amount of time (in seconds) that an object is in a CloudFront cache<br>    before CloudFront forwards another request in the absence of an Cache-Control<br>    max-age or Expires header. | `number` | `3600` | no |
| <a name="input_cloudfront_cache_max_ttl"></a> [cloudfront\_cache\_max\_ttl](#input\_cloudfront\_cache\_max\_ttl) | Specify the maximum amount of time, in seconds, that you want objects to stay<br>    in CloudFront caches before CloudFront queries your origin to see whether the<br>    object has been updated. The value that you specify for Maximum TTL applies<br>    only when your origin adds HTTP headers such as `Cache-Control max-age`,<br>    `Cache-Control s-maxage`, or `Expires` to objects. | `number` | `86400` | no |
| <a name="input_cloudfront_cache_min_ttl"></a> [cloudfront\_cache\_min\_ttl](#input\_cloudfront\_cache\_min\_ttl) | Specify the minimum amount of time, in seconds, that you want objects to stay<br>    in the CloudFront cache before CloudFront sends another request to the origin<br>    to determine whether the object has been updated. | `number` | `0` | no |
| <a name="input_cloudfront_cache_policy_cookie_behavior"></a> [cloudfront\_cache\_policy\_cookie\_behavior](#input\_cloudfront\_cache\_policy\_cookie\_behavior) | Whether any cookies in viewer requests are included in the cache key and<br>    automatically included in requests that CloudFront sends to the origin.<br>    Valid values for cookie\_behavior are `none`, `whitelist`, `allExcept`, and<br>    `all`. | `string` | `"none"` | no |
| <a name="input_cloudfront_cache_policy_cookies"></a> [cloudfront\_cache\_policy\_cookies](#input\_cloudfront\_cache\_policy\_cookies) | List of cookie names used by cloudfront\_cache\_policy\_cookie\_behavior | `list(string)` | `[]` | no |
| <a name="input_cloudfront_cache_policy_field_level_encryption_id"></a> [cloudfront\_cache\_policy\_field\_level\_encryption\_id](#input\_cloudfront\_cache\_policy\_field\_level\_encryption\_id) | The ID of the field-level encryption configuration that you want CloudFront<br>        to use for encrypting specific fields of data for a cache behavior or for<br>        the default cache behavior in your distribution. | `string` | `""` | no |
| <a name="input_cloudfront_cache_policy_header_behavior"></a> [cloudfront\_cache\_policy\_header\_behavior](#input\_cloudfront\_cache\_policy\_header\_behavior) | Whether any HTTP headers are included in the cache key and automatically<br>    included in requests that CloudFront sends to the origin. Valid values for<br>    header\_behavior are `none` and `whitelist`. | `string` | `"none"` | no |
| <a name="input_cloudfront_cache_policy_headers"></a> [cloudfront\_cache\_policy\_headers](#input\_cloudfront\_cache\_policy\_headers) | List of header names used by cloudfront\_cache\_policy\_header\_behavior | `list(string)` | `[]` | no |
| <a name="input_cloudfront_cache_policy_query_string_behavior"></a> [cloudfront\_cache\_policy\_query\_string\_behavior](#input\_cloudfront\_cache\_policy\_query\_string\_behavior) | Whether URL query strings in viewer requests are included in the cache key<br>    and automatically included in requests that CloudFront sends to the origin.<br>    Valid values for query\_string\_behavior are `none`, `whitelist`, `allExcept`,<br>    and `all`. | `string` | `"none"` | no |
| <a name="input_cloudfront_cache_policy_query_strings"></a> [cloudfront\_cache\_policy\_query\_strings](#input\_cloudfront\_cache\_policy\_query\_strings) | List of query string names used by<br>    cloudfront\_cache\_policy\_query\_string\_behavior | `list(string)` | `[]` | no |
| <a name="input_cloudfront_cached_methods"></a> [cloudfront\_cached\_methods](#input\_cloudfront\_cached\_methods) | CloudFront Cached Methods -<br>    Controls whether CloudFront caches the response to requests using the<br>    specified HTTP methods. | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cloudfront_comment"></a> [cloudfront\_comment](#input\_cloudfront\_comment) | Comment for the CloudFront Distribution | `string` | `"CloudFront Distribution for Static Website"` | no |
| <a name="input_cloudfront_custom_error_min_ttl"></a> [cloudfront\_custom\_error\_min\_ttl](#input\_cloudfront\_custom\_error\_min\_ttl) | The minimum amount of time, in seconds, that you want CloudFront to cache<br>    the HTTP status code specified in ErrorCode. | `number` | `0` | no |
| <a name="input_cloudfront_custom_error_response_error_code"></a> [cloudfront\_custom\_error\_response\_error\_code](#input\_cloudfront\_custom\_error\_response\_error\_code) | 4xx or 5xx HTTP status code that you want to customize | `number` | `404` | no |
| <a name="input_cloudfront_custom_error_response_page_path"></a> [cloudfront\_custom\_error\_response\_page\_path](#input\_cloudfront\_custom\_error\_response\_page\_path) | HTML page you want CloudFront to return with the custom error response to the viewer. | `string` | `"/error.html"` | no |
| <a name="input_cloudfront_custom_error_response_response_code"></a> [cloudfront\_custom\_error\_response\_response\_code](#input\_cloudfront\_custom\_error\_response\_response\_code) | The HTTP status code that you want CloudFront to return to the viewer<br>    along with the custom error page. | `number` | `200` | no |
| <a name="input_cloudfront_default_root_object"></a> [cloudfront\_default\_root\_object](#input\_cloudfront\_default\_root\_object) | The default index page that CloudFront will serve when no path is provided. | `string` | `"index.html"` | no |
| <a name="input_cloudfront_enabled"></a> [cloudfront\_enabled](#input\_cloudfront\_enabled) | Enable the Cloudfront Distribution? | `bool` | `true` | no |
| <a name="input_cloudfront_geo_restriction_locations"></a> [cloudfront\_geo\_restriction\_locations](#input\_cloudfront\_geo\_restriction\_locations) | ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute<br>    your content (whitelist) or not distribute your content (blacklist).<br>    See https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 for a list of codes. | `list(string)` | `[]` | no |
| <a name="input_cloudfront_geo_restriction_type"></a> [cloudfront\_geo\_restriction\_type](#input\_cloudfront\_geo\_restriction\_type) | Method that you want to use to restrict distribution of your content by<br>  country: `none`, `whitelist`, or `blacklist`. | `string` | `"none"` | no |
| <a name="input_cloudfront_ipv6_enabled"></a> [cloudfront\_ipv6\_enabled](#input\_cloudfront\_ipv6\_enabled) | Whether the IPv6 protocol is enabled for the distribution. | `bool` | `true` | no |
| <a name="input_cloudfront_logging"></a> [cloudfront\_logging](#input\_cloudfront\_logging) | Whether CloudFront logs requests. | `bool` | `true` | no |
| <a name="input_cloudfront_logging_cookies"></a> [cloudfront\_logging\_cookies](#input\_cloudfront\_logging\_cookies) | Whether CloudFront logs cookies. | `bool` | `false` | no |
| <a name="input_cloudfront_logging_prefix"></a> [cloudfront\_logging\_prefix](#input\_cloudfront\_logging\_prefix) | Logging prefix for CloudFront logs. If you don't specify a prefix, the<br>  prefix will be the website hostname with dashes instead of dots. | `string` | `""` | no |
| <a name="input_cloudfront_maximum_http_version"></a> [cloudfront\_maximum\_http\_version](#input\_cloudfront\_maximum\_http\_version) | Maximum HTTP version to support on the distribution. Allowed values are<br>  `http1.1`, `http2`, `http2and3`, `http3`. | `string` | `"http2"` | no |
| <a name="input_cloudfront_origin_connection_attempts"></a> [cloudfront\_origin\_connection\_attempts](#input\_cloudfront\_origin\_connection\_attempts) | The number of times that CloudFront attempts to connect to the origin. | `number` | `3` | no |
| <a name="input_cloudfront_origin_connection_timeout"></a> [cloudfront\_origin\_connection\_timeout](#input\_cloudfront\_origin\_connection\_timeout) | The number of seconds that CloudFront waits when trying to establish a<br>    connection to the origin. | `number` | `10` | no |
| <a name="input_cloudfront_origin_custom_headers"></a> [cloudfront\_origin\_custom\_headers](#input\_cloudfront\_origin\_custom\_headers) | Custom Headers to send to the origin.<br>      By default there is a limit of 10 headers. A call to AWS Support can increase<br>      this limit. | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | Which CloudFront Price Class to use. Consult this table:<br>  https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html | `string` | `"PriceClass_100"` | no |
| <a name="input_cloudfront_realtime_log_config_arn"></a> [cloudfront\_realtime\_log\_config\_arn](#input\_cloudfront\_realtime\_log\_config\_arn) | The ARN of the Kinesis Firehose stream that receives real-time log data<br>    from CloudFront. | `string` | `""` | no |
| <a name="input_cloudfront_retain_on_delete"></a> [cloudfront\_retain\_on\_delete](#input\_cloudfront\_retain\_on\_delete) | Retain the CloudFront Distribution when the Terraform resource is deleted. | `bool` | `false` | no |
| <a name="input_cloudfront_viewer_security_policy"></a> [cloudfront\_viewer\_security\_policy](#input\_cloudfront\_viewer\_security\_policy) | Which Security Policy to use. Consult this table:<br>  https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_cloudfront_viewer_ssl_support_method"></a> [cloudfront\_viewer\_ssl\_support\_method](#input\_cloudfront\_viewer\_ssl\_support\_method) | Which SSL support method to use. `sni-only` or `vip` supported<br><br>  **PLEASE NOTE:** that setting this value to `vip` will incur **significant<br>  additional charges**.<br><br>  Please read this prior to setting this value to `vip`:<br>  https://aws.amazon.com/cloudfront/pricing/ | `string` | `"sni-only"` | no |
| <a name="input_cloudfront_wait_for_deployment"></a> [cloudfront\_wait\_for\_deployment](#input\_cloudfront\_wait\_for\_deployment) | Wait for the CloudFront Distribution to be deployed before continuing. | `bool` | `false` | no |
| <a name="input_dns_type"></a> [dns\_type](#input\_dns\_type) | Either `aws` or `gandi` depending on where your DNS Zone is hosted | `string` | `"aws"` | no |
| <a name="input_gandi_key"></a> [gandi\_key](#input\_gandi\_key) | Gandi API Key - Required if using Gandi for DNS | `string` | `""` | no |
| <a name="input_gandi_sharing_id"></a> [gandi\_sharing\_id](#input\_gandi\_sharing\_id) | Gandi API Sharing ID - Optional<br>  See:  https://api.gandi.net/docs/reference/#Sharing-ID | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to use for S3 Buckets | `string` | `"us-west-2"` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route 53 Zone ID for website TLD | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_cloudfront_logs_arn"></a> [bucket\_cloudfront\_logs\_arn](#output\_bucket\_cloudfront\_logs\_arn) | CLoudFront Standard Logs Bucket ARN |
| <a name="output_bucket_cloudfront_logs_bucket_key_enabled"></a> [bucket\_cloudfront\_logs\_bucket\_key\_enabled](#output\_bucket\_cloudfront\_logs\_bucket\_key\_enabled) | CloudFront Standard Logs Bucket Key Enabled |
| <a name="output_bucket_cloudfront_logs_bucket_sse_algo"></a> [bucket\_cloudfront\_logs\_bucket\_sse\_algo](#output\_bucket\_cloudfront\_logs\_bucket\_sse\_algo) | SSE Algorithm for CloudFront Standard Logs Bucket |
| <a name="output_bucket_cloudfront_logs_bucket_sse_kms_key_id"></a> [bucket\_cloudfront\_logs\_bucket\_sse\_kms\_key\_id](#output\_bucket\_cloudfront\_logs\_bucket\_sse\_kms\_key\_id) | SSE KMS Key ID for CloudFront Standard Logs Bucket |
| <a name="output_bucket_cloudfront_logs_force_destroy"></a> [bucket\_cloudfront\_logs\_force\_destroy](#output\_bucket\_cloudfront\_logs\_force\_destroy) | Is force destroy set for the CloudFront Standard Logs bucket? |
| <a name="output_bucket_cloudfront_logs_id"></a> [bucket\_cloudfront\_logs\_id](#output\_bucket\_cloudfront\_logs\_id) | CloudFront Standard Logs Bucket ID |
| <a name="output_bucket_cloudfront_logs_oac_policy"></a> [bucket\_cloudfront\_logs\_oac\_policy](#output\_bucket\_cloudfront\_logs\_oac\_policy) | CloudFront Origin Access Control |
| <a name="output_bucket_cloudfront_logs_region"></a> [bucket\_cloudfront\_logs\_region](#output\_bucket\_cloudfront\_logs\_region) | CloudFront Standard Logs S3 Bucket Region |
| <a name="output_bucket_cloudfront_logs_versioning_enabled"></a> [bucket\_cloudfront\_logs\_versioning\_enabled](#output\_bucket\_cloudfront\_logs\_versioning\_enabled) | Whether versioning is enabled on the CloudFront logs bucket |
| <a name="output_bucket_cloudfront_logs_versioning_mfa_delete"></a> [bucket\_cloudfront\_logs\_versioning\_mfa\_delete](#output\_bucket\_cloudfront\_logs\_versioning\_mfa\_delete) | Whether MFA delete is enabled on the CloudFront logs bucket |
| <a name="output_bucket_website_arn"></a> [bucket\_website\_arn](#output\_bucket\_website\_arn) | Static asset S3 Bucket ARN |
| <a name="output_bucket_website_bucket_key_enabled"></a> [bucket\_website\_bucket\_key\_enabled](#output\_bucket\_website\_bucket\_key\_enabled) | Website Bucket Key Enabled |
| <a name="output_bucket_website_bucket_sse_algo"></a> [bucket\_website\_bucket\_sse\_algo](#output\_bucket\_website\_bucket\_sse\_algo) | SSE Algorithm for Website Bucket |
| <a name="output_bucket_website_bucket_sse_kms_key_id"></a> [bucket\_website\_bucket\_sse\_kms\_key\_id](#output\_bucket\_website\_bucket\_sse\_kms\_key\_id) | SSE KMS Key ID for Website Bucket |
| <a name="output_bucket_website_force_destroy"></a> [bucket\_website\_force\_destroy](#output\_bucket\_website\_force\_destroy) | Is force destroy set for the static asset bucket? |
| <a name="output_bucket_website_id"></a> [bucket\_website\_id](#output\_bucket\_website\_id) | Static asset S3 Bucket ID |
| <a name="output_bucket_website_region"></a> [bucket\_website\_region](#output\_bucket\_website\_region) | Static asset S3 Bucket Region |
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
| <a name="output_cloudfront_enabled"></a> [cloudfront\_enabled](#output\_cloudfront\_enabled) | Boolean to determine if CloudFront is enabled |
| <a name="output_cloudfront_logging"></a> [cloudfront\_logging](#output\_cloudfront\_logging) | Is CloudFront logging enabled? |
| <a name="output_cloudfront_logging_prefix"></a> [cloudfront\_logging\_prefix](#output\_cloudfront\_logging\_prefix) | CloudFront Logging Prefix. Can be used in a lifecycle rule filter |
| <a name="output_cloudfront_origin_access_control_id"></a> [cloudfront\_origin\_access\_control\_id](#output\_cloudfront\_origin\_access\_control\_id) | CloudFront Origin Access Control |
| <a name="output_dns_website_record"></a> [dns\_website\_record](#output\_dns\_website\_record) | This is the Website DNS Record |
| <a name="output_dns_website_record_target"></a> [dns\_website\_record\_target](#output\_dns\_website\_record\_target) | This is the CloudFront Distribution Domain Name |
| <a name="output_z_gandi_domain"></a> [z\_gandi\_domain](#output\_z\_gandi\_domain) | Are we a Gandi Domain Boolean |
| <a name="output_z_valid_inputs"></a> [z\_valid\_inputs](#output\_z\_valid\_inputs) | Will be true if all inputs are valid |
<!-- END_TF_DOCS -->
