#---------
# S3
#---------
output "bucket-website-id" {
  description = "Static asset Bucket ID"
  value       = module.site.bucket-website-id
}

output "bucket-website-arn" {
  description = "Static asset S3 Bucket ARN"
  value       = module.site.bucket-website-arn
}

output "bucket-website-force-destroy" {
  description = "Is force destroy set for the static asset bucket?"
  value       = module.site.bucket-website-force-destroy
}

output "bucket-website-region" {
  description = "Static asset Bucket Region"
  value       = module.site.bucket-website-region
}

output "bucket-website-versioning-enabled" {
  description = "Static asset Bucket Versioning"
  value       = module.site.bucket-website-versioning-enabled
}

output "bucket-website-versioning-mfa-delete" {
  description = "Static asset Bucket Versioning MFA Delete"
  value       = module.site.bucket-website-versioning-mfa-delete
}
output "cloudfront_logging" {
  description = "Is CloudFront logging enabled?"
  value       = module.site.cloudfront_logging
}

output "bucket-cloudfront-logs-versioning-enabled" {
  description = "CloudFront Logging Bucket Versioning"
  value       = module.site.bucket-cloudfront-logs-versioning-enabled
}

output "bucket-cloudfront-logs-versioning-mfa-delete" {
  description = "CloudFront Logging Bucket Versioning MFA Delete"
  value       = module.site.bucket-cloudfront-logs-versioning-mfa-delete
}

output "bucket-cloudfront-logs-oac-policy" {
  description = "CloudFront Origin Access Control"
  value       = module.site.bucket-cloudfront-logs-oac-policy
}


output "bucket-cloudfront-logs-id" {
  description = "CloudFront Logging Bucket ID"
  value       = module.site.bucket-cloudfront-logs-id
}

output "bucket-cloudfront-logs-arn" {
  description = "CLoudFront Standard Loggiing Bucket ARN"
  value       = module.site.bucket-cloudfront-logs-arn
}

output "bucket-cloudfront-logs-force-destroy" {
  description = "Is force destroy set for the CloudFront Standard Logging bucket?"
  value       = module.site.bucket-cloudfront-logs-force-destroy
}

output "bucket-cloudfront-logs-bucket-key-enabled" {
  description = "CloudFront Standard Logging Bucket Key Enabled"
  value       = module.site.bucket-cloudfront-logs-bucket-key-enabled
}

output "bucket-cloudfront-logs-bucket-sse-algo" {
  description = "SSE Algorithm for CloudFront Standard Logging Bucket"
  value       = module.site.bucket-cloudfront-logs-bucket-sse-algo
}

output "bucket-cloudfront-logs-bucket-sse-kms-key-id" {
  description = "SSE KMS Key ID for CloudFront Standard Logging Bucket"
  value       = module.site.bucket-cloudfront-logs-bucket-sse-kms-key-id
}

#---------
# ACM
#---------
output "certificate-website-domain-name" {
  description = "Site Certificate domain name"
  value       = module.site.certificate-website-domain-name
}

output "certificate-website-arn" {
  description = "Site Certificate ARN"
  value       = module.site.certificate-website-arn
}

output "certificate-website-status" {
  description = "Site Certificate provisioning status"
  value       = module.site.certificate-website-status
}

output "certificate-website-domain-validation-name" {
  description = "The resource record name for domain validation."
  value       = module.site.certificate-website-domain-validation-name
}

output "certificate-website-domain-validation-type" {
  description = "The resource record type for domain validation."
  value       = module.site.certificate-website-domain-validation-type
}

output "certificate-website-domain-validation-value" {
  description = "The resource record value for domain validation."
  value       = module.site.certificate-website-domain-validation-value
}

output "certificate-website-expiration" {
  description = "Site Certificate Expiration"
  value       = module.site.certificate-website-expiration
}

output "certificate-website-issued" {
  description = "Site Certificate Issued"
  value       = module.site.certificate-website-issued
}

#---------
# CloudFront
#---------
output "cloudfront-distribution-id" {
  description = "CloudFront Distribution ID"
  value       = module.site.cloudfront-distribution-id
}

output "cloudfront-distribution-arn" {
  description = "CloudFront Distribution ARN"
  value       = module.site.cloudfront-distribution-arn
}

output "cloudfront-distribution-domain-name" {
  description = "CloudFront Distribution Domain Name"
  value       = module.site.cloudfront-distribution-domain-name
}

output "cloudfront-distribution-zone-id" {
  description = "CloudFront Distribution Zone ID"
  value       = module.site.cloudfront-distribution-zone-id
}

output "cloudfront-distribution-status" {
  description = "CloudFront Distribution Status"
  value       = module.site.cloudfront-distribution-status
}

output "cloudfront-distribution-http-version" {
  description = "CloudFront Distribution HTTP Version"
  value       = module.site.cloudfront-distribution-http-version
}

output "cloudfront-distribution-http-last-modified-time" {
  description = "CloudFront Distribution Last Modified"
  value       = module.site.cloudfront-distribution-http-last-modified-time
}

output "cloudfront-enabled" {
  description = "CloudFront Enabled"
  value       = module.site.cloudfront-enabled
}

output "cloudfront-origin-access-control-id" {
  description = "CloudFront Origin Access Control"
  value       = module.site.cloudfront-origin-access-control-id
}

#---------
# DNS
#---------
output "website-domain-resource-id" {
  description = "Website DNS Record ID"
  value       = module.site.website-domain-resource-id
}

output "website-domain-target" {
  description = "Website DNS Record Target"
  value       = module.site.website-domain-target
}

output "website-dns-record" {
  description = "Website DNS Record Name"
  value       = module.site.website-dns-record
}

# Deployment Type Booleans
output "z-is-gandi-domain" {
  description = "True if deployment DNS is using Gandi"
  value       = module.site.gandi-domain
}

output "z-is-route53-domain" {
  description = "True if deployment DNS is using Route 53"
  value       = !module.site.gandi-domain
}

output "z-valid-inputs" {
  value       = module.site.z-valid-inputs
  description = "Will be true if all inputs are valid"
}

output "z-website-url" {
  description = "Website URL"
  value       = "https://${module.site.certificate-website-domain-name}/"
}
