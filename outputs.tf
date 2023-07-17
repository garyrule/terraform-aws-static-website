#---------
# S3
#---------
output "bucket-website-id" {
  description = "Static asset S3 Bucket ID"
  value       = aws_s3_bucket.site.id
}

output "bucket-website-arn" {
  description = "Static asset S3 Bucket ARN"
  value       = aws_s3_bucket.site.arn
}

output "bucket-website-force-destroy" {
  description = "Is force destroy set for the static asset bucket?"
  value       = aws_s3_bucket.site.force_destroy
}

output "bucket-website-region" {
  description = "Static asset S3 Bucket Region"
  value       = aws_s3_bucket.site.region
}

output "bucket-website-versioning-enabled" {
  description = "Static asset Bucket Versioning"
  value       = aws_s3_bucket.site.versioning[0].enabled
}

output "bucket-website-versioning-mfa-delete" {
  description = "Static asset Bucket Versioning MFA Delete"
  value       = aws_s3_bucket.site.versioning[0].mfa_delete
}

output "cloudfront_logging" {
  description = "Is CloudFront logging enabled?"
  value       = var.cloudfront_logging
}

output "bucket-cloudfront-logs-id" {
  description = "CloudFront Standard Logging Bucket ID"
  value       = one(aws_s3_bucket.cloudfront_logs[*].id)
}

output "bucket-cloudfront-logs-arn" {
  description = "CLoudFront Standard Loggiing Bucket ARN"
  value       = one(aws_s3_bucket.cloudfront_logs[*].arn)
}

output "bucket-cloudfront-logs-force-destroy" {
  description = "Is force destroy set for the CloudFront Standard Logging bucket?"
  value       = one(aws_s3_bucket.cloudfront_logs[*].force_destroy)
}

output "bucket-cloudfront-logs-bucket-key-enabled" {
  description = "CloudFront Standard Logging Bucket Key Enabled"
  value       = element([for rule in aws_s3_bucket_server_side_encryption_configuration.site.rule : rule.bucket_key_enabled], 0)
}

output "bucket-cloudfront-logs-bucket-sse-algo" {
  description = "SSE Algorithm for CloudFront Standard Logging Bucket"
  value       = element([for rule in aws_s3_bucket_server_side_encryption_configuration.site.rule : rule.apply_server_side_encryption_by_default[0].sse_algorithm], 0)
}

output "bucket-cloudfront-logs-bucket-sse-kms-key-id" {
  description = "SSE KMS Key ID for CloudFront Standard Logging Bucket"
  value       = element([for rule in aws_s3_bucket_server_side_encryption_configuration.site.rule : rule.apply_server_side_encryption_by_default[0].kms_master_key_id], 0)
}

output "bucket-cloudfront-logs-versioning-enabled" {
  description = "Whether versioning is enabled on the CloudFront logs bucket"
  value       = var.cloudfront_logging ? element(aws_s3_bucket.cloudfront_logs[*].versioning[0].enabled, 0) : null
}

output "bucket-cloudfront-logs-versioning-mfa-delete" {
  description = "Whether MFA delete is enabled on the CloudFront logs bucket"
  value       = var.cloudfront_logging ? element(aws_s3_bucket.cloudfront_logs[*].versioning[0].mfa_delete, 0) : null
}

output "bucket-cloudfront-logs-oac-policy" {
  description = "CloudFront Origin Access Control"
  value       = aws_s3_bucket_policy.site.policy
}

#---------
# ACM
#---------
output "certificate-website-domain-name" {
  description = "Site Certificate domain name"
  value       = aws_acm_certificate.site.domain_name
}

output "certificate-website-arn" {
  description = "Site Certificate ARN"
  value       = aws_acm_certificate.site.arn
}

output "certificate-website-status" {
  description = "Site Certificate provisioning status"
  value       = aws_acm_certificate.site.status
}

output "certificate-website-domain-validation-name" {
  description = "The resource record name for domain validation."
  value       = tolist(aws_acm_certificate.site.domain_validation_options)[0]["resource_record_name"]
}

output "certificate-website-domain-validation-type" {
  description = "The resource record type for domain validation."
  value       = tolist(aws_acm_certificate.site.domain_validation_options)[0]["resource_record_type"]
}

output "certificate-website-domain-validation-value" {
  description = "The resource record value for domain validation."
  value       = tolist(aws_acm_certificate.site.domain_validation_options)[0]["resource_record_value"]
}

output "certificate-website-expiration" {
  description = "Site Certificate Expiration"
  value       = aws_acm_certificate.site.not_after
}

output "certificate-website-issued" {
  description = "Site Certificate Issued"
  value       = aws_acm_certificate.site.not_before
}

#---------
# CloudFront
#---------
output "cloudfront-distribution-id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront-distribution-arn" {
  description = "CloudFront Distribution ARN"
  value       = aws_cloudfront_distribution.site.arn
}

output "cloudfront-distribution-domain-name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront-distribution-zone-id" {
  description = "CloudFront Distribution Zone ID"
  value       = aws_cloudfront_distribution.site.hosted_zone_id
}

output "cloudfront-distribution-status" {
  description = "CloudFront Distribution Status"
  value       = aws_cloudfront_distribution.site.status
}

output "cloudfront-distribution-http-version" {
  description = "CloudFront Distribution HTTP Version"
  value       = aws_cloudfront_distribution.site.http_version
}

output "cloudfront-distribution-http-last-modified-time" {
  description = "CloudFront Distribution Last Modified"
  value       = aws_cloudfront_distribution.site.last_modified_time
}

output "cloudfront-origin-access-control-id" {
  description = "CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.site.id
}

output "cloudfront-enabled" {
  description = "Boolean to determine if CloudFront is enabled"
  value       = aws_cloudfront_distribution.site.enabled
}

#---------
# DNS
#---------
output "website-domain-resource-id" {
  description = "Website DNS Record Resource ID"
  value       = length(local.website-domain-resource-id) > 0 ? local.website-domain-resource-id[0] : null
}

output "website-dns-record" {
  description = "Website DNS Record Name"
  value       = local.website-dns-record
}

output "website-domain-target" {
  description = "Website DNS Record Target"
  value       = length(local.website-domain-target) > 0 ? local.website-domain-target[0] : null
}

output "gandi-domain" {
  description = "Are we a Gandi Domain Boolean "
  value       = local.gandi_zone
}

output "z-valid-inputs" {
  value       = local.validate_inputs
  description = "Will be true if all inputs are valid"
}
