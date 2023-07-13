#---------
# S3
#---------
output "bucket-id" {
  description = "Static file S3 Bucket ID"
  value       = aws_s3_bucket.site.id
}

output "bucket-region" {
  description = "Static file S3 Bucket Region"
  value       = aws_s3_bucket.site.region
}

output "bucket-hosted-zone-id" {
  description = "Static file Bucket Zone ID"
  value       = aws_s3_bucket.site.hosted_zone_id
}

output "bucket-versioning" {
  description = "Static file Bucket Versioning"
  value       = aws_s3_bucket.site.versioning
}

output "s3_bucket_policy" {
  description = "Cloudfront Origin Access Control"
  value       = aws_s3_bucket_policy.site.policy
}

#---------
# ACM
#---------
output "site-certificate-domain-name" {
  description = "Site Certificate domain name"
  value       = aws_acm_certificate.site.domain_name
}

output "site-certificate-arn" {
  description = "Site Certificate ARN"
  value       = aws_acm_certificate.site.arn
}

output "site-certificate-status" {
  description = "Site Certificate provisioning status"
  value       = aws_acm_certificate.site.status
}

output "site-certificate-domain-validation-options" {
  description = "Site Certificate Domain Validation Options"
  value       = aws_acm_certificate.site.domain_validation_options
}

output "site-certificate-expiration" {
  description = "Site Certificate Expiration"
  value       = aws_acm_certificate.site.not_after
}

output "site-certificate-issued" {
  description = "Site Certificate Issued"
  value       = aws_acm_certificate.site.not_before
}

output "certificate-validation-domain-name" {
  description = "Certificate Validation, validation record FQDNs"
  value       = local.certificate_validation_record_fqdns
}

#---------
# Cloudfront
#---------
output "cloudfront-distribution-id" {
  description = "Cloudfront Distribution ID"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront-distribution-domain-name" {
  description = "Cloudfront Distribution Domain Name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront-distribution-zone-id" {
  description = "Cloudfront Distribution Zone ID"
  value       = aws_cloudfront_distribution.site.hosted_zone_id
}

output "cloudfront-distribution-status" {
  description = "Cloudfront Distribution Status"
  value       = aws_cloudfront_distribution.site.status
}

output "cloudfront-distribution-http-version" {
  description = "Cloudfront Distribution HTTP Version"
  value       = aws_cloudfront_distribution.site.http_version
}

output "cloudfront-distribution-http-last-modified-time" {
  description = "Cloudfront Distribution Last Modified"
  value       = aws_cloudfront_distribution.site.last_modified_time
}

output "cloudfront-origin-access-control-id" {
  description = "Cloudfront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.site.id
}

#---------
# DNS
#---------
output "dns-site-id" {
  description = "DNS Site ID"
  value       = local.dns-site-id
}

output "dns-site-name" {
  description = "DNS Site Name"
  value       = local.dns-site-name
}

output "dns-site-alias" {
  description = "DNS Site Alias"
  value       = local.dns-site-alias
}

output "gandi-domain" {
  description = "Are we a Gandi Domain Boolean "
  value       = local.gandi_zone
}
