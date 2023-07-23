#_________
# S3
#_________
output "bucket_website_id" {
  description = "Static asset Bucket ID"
  value       = module.site.bucket_website_id
}

output "bucket_website_arn" {
  description = "Static asset S3 Bucket ARN"
  value       = module.site.bucket_website_arn
}

output "bucket_website_force_destroy" {
  description = "Is force destroy set for the static asset bucket?"
  value       = module.site.bucket_website_force_destroy
}

output "bucket_website_region" {
  description = "Static asset Bucket Region"
  value       = module.site.bucket_website_region
}

output "bucket_website_bucket_key_enabled" {
  description = "Website Bucket Key Enabled"
  value       = module.site.bucket_website_bucket_key_enabled
}

output "bucket_website_bucket_sse_algo" {
  description = "SSE Algorithm for Website Bucket"
  value       = module.site.bucket_website_bucket_sse_algo
}

output "bucket_website_bucket_sse_kms_key_id" {
  description = "SSE KMS Key ID for Website Bucket"
  value       = module.site.bucket_website_bucket_sse_kms_key_id
}

output "bucket_website_versioning_enabled" {
  description = "Static asset Bucket Versioning"
  value       = module.site.bucket_website_versioning_enabled
}

output "bucket_website_versioning_mfa_delete" {
  description = "Static asset Bucket Versioning MFA Delete"
  value       = module.site.bucket_website_versioning_mfa_delete
}
output "cloudfront_logging" {
  description = "Is CloudFront logging enabled?"
  value       = module.site.cloudfront_logging
}

output "cloudfront_logging_prefix" {
  description = "CloudFront Logging Prefix. Can be used in a lifecycle rule filter"
  value       = module.site.cloudfront_logging_prefix
}

output "bucket_cloudfront_logs_versioning_enabled" {
  description = "CloudFront Logging Bucket Versioning"
  value       = module.site.bucket_cloudfront_logs_versioning_enabled
}

output "bucket_cloudfront_logs_versioning_mfa_delete" {
  description = "CloudFront Logging Bucket Versioning MFA Delete"
  value       = module.site.bucket_cloudfront_logs_versioning_mfa_delete
}

output "bucket_cloudfront_logs_oac_policy" {
  description = "CloudFront Origin Access Control"
  value       = module.site.bucket_cloudfront_logs_oac_policy
}


output "bucket_cloudfront_logs_id" {
  description = "CloudFront Logging Bucket ID"
  value       = module.site.bucket_cloudfront_logs_id
}

output "bucket_cloudfront_logs_arn" {
  description = "CloudFront Standard Logging Bucket ARN"
  value       = module.site.bucket_cloudfront_logs_arn
}

output "bucket_cloudfront_logs_force_destroy" {
  description = "Is force destroy set for the CloudFront Standard Logging bucket?"
  value       = module.site.bucket_cloudfront_logs_force_destroy
}

output "bucket_cloudfront_logs_region" {
  description = "CloudFront Standard Logs S3 Bucket Region"
  value       = module.site.bucket_cloudfront_logs_region
}

output "bucket_cloudfront_logs_bucket_key_enabled" {
  description = "CloudFront Standard Logs Bucket Key Enabled"
  value       = module.site.bucket_cloudfront_logs_bucket_key_enabled
}

output "bucket_cloudfront_logs_bucket_sse_algo" {
  description = "SSE Algorithm for CloudFront Standard Logs Bucket"
  value       = module.site.bucket_cloudfront_logs_bucket_sse_algo
}

output "bucket_cloudfront_logs_bucket_sse_kms_key_id" {
  description = "SSE KMS Key ID for CloudFront Standard Logs Bucket"
  value       = module.site.bucket_cloudfront_logs_bucket_sse_kms_key_id
}

output "cloudfront_cache_policy_id" {
  description = "CloudFront Cache Policy ID"
  value       = module.site.cloudfront_cache_policy_id
}

#_________
# ACM
#_________
output "certificate_website_domain_name" {
  description = "Site Certificate domain name"
  value       = module.site.certificate_website_domain_name
}

output "certificate_website_arn" {
  description = "Site Certificate ARN"
  value       = module.site.certificate_website_arn
}

output "certificate_website_status" {
  description = "Site Certificate provisioning status"
  value       = module.site.certificate_website_status
}

output "certificate_website_domain_validation_name" {
  description = "The resource record name for domain validation."
  value       = module.site.certificate_website_domain_validation_name
}

output "certificate_website_domain_validation_type" {
  description = "The resource record type for domain validation."
  value       = module.site.certificate_website_domain_validation_type
}

output "certificate_website_domain_validation_value" {
  description = "The resource record value for domain validation."
  value       = module.site.certificate_website_domain_validation_value
}

output "certificate_website_expiration" {
  description = "Site Certificate Expiration"
  value       = module.site.certificate_website_expiration
}

output "certificate_website_issued" {
  description = "Site Certificate Issued"
  value       = module.site.certificate_website_issued
}

#_________
# CloudFront
#_________
output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = module.site.cloudfront_distribution_id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN"
  value       = module.site.cloudfront_distribution_arn
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = module.site.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_zone_id" {
  description = "CloudFront Distribution Zone ID"
  value       = module.site.cloudfront_distribution_zone_id
}

output "cloudfront_distribution_status" {
  description = "CloudFront Distribution Status"
  value       = module.site.cloudfront_distribution_status
}

output "cloudfront_distribution_http_version" {
  description = "CloudFront Distribution HTTP Version"
  value       = module.site.cloudfront_distribution_http_version
}

output "cloudfront_distribution_http_last_modified_time" {
  description = "CloudFront Distribution Last Modified"
  value       = module.site.cloudfront_distribution_http_last_modified_time
}

output "cloudfront_origin_access_control_id" {
  description = "CloudFront Origin Access Control"
  value       = module.site.cloudfront_origin_access_control_id
}

output "cloudfront_enabled" {
  description = "CloudFront Enabled"
  value       = module.site.cloudfront_enabled
}

#_________
# DNS
#_________
output "dns_website_record" {
  description = "Website DNS Record Name"
  #  description = "This is the Website DNS Record"
  value = module.site.dns_website_record
}

output "dns_website_record_target" {
  description = "Website DNS Record Target"
  #  description = "This is the CloudFront Distribution Domain Name"
  value = module.site.dns_website_record_target
}

output "z_gandi_domain" {
  description = "True if deployment DNS is using Gandi"
  value       = module.site.z_gandi_domain
}

output "z_route53_domain" {
  description = "True if deployment DNS is using Route 53"
  value       = !module.site.z_gandi_domain
}

#--------
# DNS Type and Input Validation Booleans
#--------
output "z_valid_inputs" {
  value       = module.site.z_valid_inputs
  description = "Will be true if all inputs are valid"
}

output "z_website_url" {
  description = "Website URL"
  value       = "https://${module.site.certificate_website_domain_name}/"
}
