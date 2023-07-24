#_________
# S3
#_________
output "bucket_website_id" {
  description = "Static asset S3 Bucket ID"
  value       = aws_s3_bucket.site.id
}

output "bucket_website_arn" {
  description = "Static asset S3 Bucket ARN"
  value       = aws_s3_bucket.site.arn
}

output "bucket_website_force_destroy" {
  description = "Is force destroy set for the static asset bucket?"
  value       = aws_s3_bucket.site.force_destroy
}

output "bucket_website_region" {
  description = "Static asset S3 Bucket Region"
  value       = aws_s3_bucket.site.region
}

output "bucket_website_bucket_key_enabled" {
  description = "Website Bucket Key Enabled"
  value       = element([for rule in aws_s3_bucket_server_side_encryption_configuration.site.rule : rule.bucket_key_enabled], 0)
}

output "bucket_website_bucket_sse_algo" {
  description = "SSE Algorithm for Website Bucket"
  value       = element([for rule in aws_s3_bucket_server_side_encryption_configuration.site.rule : rule.apply_server_side_encryption_by_default[0].sse_algorithm], 0)
}

output "bucket_website_bucket_sse_kms_key_id" {
  description = "SSE KMS Key ID for Website Bucket"
  value       = element([for rule in aws_s3_bucket_server_side_encryption_configuration.site.rule : rule.apply_server_side_encryption_by_default[0].kms_master_key_id], 0)
}

output "bucket_website_versioning_enabled" {
  description = "Static asset Bucket Versioning"
  value       = aws_s3_bucket.site.versioning[0].enabled
}

output "bucket_website_versioning_mfa_delete" {
  description = "Static asset Bucket Versioning MFA Delete"
  value       = aws_s3_bucket.site.versioning[0].mfa_delete
}

output "cloudfront_logging" {
  description = "Is CloudFront logging enabled?"
  value       = var.cloudfront_logging
}

output "cloudfront_logging_prefix" {
  description = "CloudFront Logging Prefix. Can be used in a lifecycle rule filter"
  value       = local.cloudfront_logging_prefix
}

output "bucket_cloudfront_logs_versioning_enabled" {
  description = "Whether versioning is enabled on the CloudFront logs bucket"
  value       = var.cloudfront_logging ? element(aws_s3_bucket.cloudfront_logs[*].versioning[0].enabled, 0) : null
}

output "bucket_cloudfront_logs_versioning_mfa_delete" {
  description = "Whether MFA delete is enabled on the CloudFront logs bucket"
  value       = var.cloudfront_logging ? element(aws_s3_bucket.cloudfront_logs[*].versioning[0].mfa_delete, 0) : null
}

output "bucket_cloudfront_logs_oac_policy" {
  description = "CloudFront Origin Access Control"
  value       = aws_s3_bucket_policy.site.policy
}

output "bucket_cloudfront_logs_id" {
  description = "CloudFront Standard Logs Bucket ID"
  value       = one(aws_s3_bucket.cloudfront_logs[*].id)
}

output "bucket_cloudfront_logs_arn" {
  description = "CLoudFront Standard Logs Bucket ARN"
  value       = one(aws_s3_bucket.cloudfront_logs[*].arn)
}

output "bucket_cloudfront_logs_force_destroy" {
  description = "Is force destroy set for the CloudFront Standard Logs bucket?"
  value       = one(aws_s3_bucket.cloudfront_logs[*].force_destroy)
}

output "bucket_cloudfront_logs_region" {
  description = "CloudFront Standard Logs S3 Bucket Region"
  value       = one(aws_s3_bucket.cloudfront_logs[*].region)
}

output "bucket_cloudfront_logs_bucket_key_enabled" {
  description = "CloudFront Standard Logs Bucket Key Enabled"
  value       = element([for rule in aws_s3_bucket_server_side_encryption_configuration.cloudfront_logs[0].rule : rule.bucket_key_enabled], 0)
}

output "bucket_cloudfront_logs_bucket_sse_algo" {
  description = "SSE Algorithm for CloudFront Standard Logs Bucket"
  value       = element([for rule in aws_s3_bucket_server_side_encryption_configuration.cloudfront_logs[0].rule : rule.apply_server_side_encryption_by_default[0].sse_algorithm], 0)
}

output "bucket_cloudfront_logs_bucket_sse_kms_key_id" {
  description = "SSE KMS Key ID for CloudFront Standard Logs Bucket"
  value       = element([for rule in aws_s3_bucket_server_side_encryption_configuration.cloudfront_logs[0].rule : rule.apply_server_side_encryption_by_default[0].kms_master_key_id], 0)
}

#_________
# ACM
#_________
output "certificate_website_domain_name" {
  description = "Site Certificate domain name"
  value       = aws_acm_certificate.site.domain_name
}

output "certificate_website_arn" {
  description = "Site Certificate ARN"
  value       = aws_acm_certificate.site.arn
}

output "certificate_website_status" {
  description = "Site Certificate provisioning status"
  value       = aws_acm_certificate.site.status
}

output "certificate_website_domain_validation_name" {
  description = "The resource record name for domain validation."
  value       = tolist(aws_acm_certificate.site.domain_validation_options)[0]["resource_record_name"]
}

output "certificate_website_domain_validation_type" {
  description = "The resource record type for domain validation."
  value       = tolist(aws_acm_certificate.site.domain_validation_options)[0]["resource_record_type"]
}

output "certificate_website_domain_validation_value" {
  description = "The resource record value for domain validation."
  value       = tolist(aws_acm_certificate.site.domain_validation_options)[0]["resource_record_value"]
}

output "certificate_website_expiration" {
  description = "Site Certificate Expiration"
  value       = aws_acm_certificate.site.not_after
}

output "certificate_website_issued" {
  description = "Site Certificate Issued"
  value       = aws_acm_certificate.site.not_before
}

#_________
# CloudFront
#_________
output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN"
  value       = aws_cloudfront_distribution.site.arn
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront_distribution_zone_id" {
  description = "CloudFront Distribution Zone ID"
  value       = aws_cloudfront_distribution.site.hosted_zone_id
}

output "cloudfront_distribution_status" {
  description = "CloudFront Distribution Status"
  value       = aws_cloudfront_distribution.site.status
}

output "cloudfront_distribution_http_version" {
  description = "CloudFront Distribution HTTP Version"
  value       = aws_cloudfront_distribution.site.http_version
}

output "cloudfront_distribution_http_last_modified_time" {
  description = "CloudFront Distribution Last Modified"
  value       = aws_cloudfront_distribution.site.last_modified_time
}

output "cloudfront_origin_access_control_id" {
  description = "CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.site.id
}

output "cloudfront_enabled" {
  description = "Boolean to determine if CloudFront is enabled"
  value       = aws_cloudfront_distribution.site.enabled
}

output "cloudfront_cache_policy_id" {
  description = "CloudFront Cache Policy ID"
  value       = aws_cloudfront_cache_policy.site.id
}

#_________
# DNS
#_________
output "dns_website_record" {
  description = "This is the Website DNS Record"
  value       = local.website_dns_record
}

output "dns_website_record_target" {
  description = "This is the CloudFront Distribution Domain Name"
  value       = length(local.website_domain_target) > 0 ? local.website_domain_target[0] : null
}

#--------
# DNS Type and Input Validation Booleans
#--------
output "z_gandi_domain" {
  description = "Are we a Gandi Domain Boolean "
  value       = local.gandi_zone
}

output "z_valid_inputs" {
  value       = local.validate_inputs
  description = "Will be true if all inputs are valid"
}
