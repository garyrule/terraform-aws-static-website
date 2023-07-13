#---------
# S3
#---------
output "bucket-id" {
  description = "Static file Bucket ID"
  value       = module.site.bucket-id
}

output "bucket-region" {
  description = "Static file Bucket Region"
  value       = module.site.bucket-region
}

#output "bucket-endpoint" {
#  description = "Static file Bucket Website Endpoint"
#  value       = module.site.bucket-endpoint
#}

output "bucket-hosted-zone-id" {
  description = "Static file Bucket Zone ID"
  value       = module.site.bucket-hosted-zone-id
}

output "bucket-versioning" {
  description = "Static file Bucket Versioning"
  value       = module.site.bucket-versioning
}

#---------
# ACM
#---------
output "site-certificate-domain-name" {
  description = "Site Certificate domain name"
  value       = module.site.site-certificate-domain-name
}

output "site-certificate-arn" {
  description = "Site Certificate ARN"
  value       = module.site.site-certificate-arn
}

output "site-certificate-status" {
  description = "Site Certificate provisioning status"
  value       = module.site.site-certificate-status
}

output "site-certificate-domain-validation-options" {
  description = "Site Certificate Domain Validation Options"
  value       = module.site.site-certificate-domain-validation-options
}

output "site-certificate-expiration" {
  description = "Site Certificate Expiration"
  value       = module.site.site-certificate-expiration
}

output "site-certificate-issued" {
  description = "Site Certificate Issued"
  value       = module.site.site-certificate-issued
}

output "certificate-validation-domain-name" {
  description = "Certificate Validation, validation record FQDNs"
  value       = module.site.certificate-validation-domain-name
}

#---------
# Cloudfront
#---------
output "cloudfront-distribution-id" {
  description = "Cloudfront Distribution ID"
  value       = module.site.cloudfront-distribution-id
}

output "cloudfront-distribution-domain-name" {
  description = "Cloudfront Distribution Domain Name"
  value       = module.site.cloudfront-distribution-domain-name
}

output "cloudfront-distribution-zone-id" {
  description = "Cloudfront Distribution Zone ID"
  value       = module.site.cloudfront-distribution-zone-id
}

output "cloudfront-distribution-status" {
  description = "Cloudfront Distribution Status"
  value       = module.site.cloudfront-distribution-status
}

output "cloudfront-distribution-http-version" {
  description = "Cloudfront Distribution HTTP Version"
  value       = module.site.cloudfront-distribution-http-version
}

output "cloudfront-distribution-http-last-modified-time" {
  description = "Cloudfront Distribution Last Modified"
  value       = module.site.cloudfront-distribution-http-last-modified-time
}

#output "referer-header-value" {
#  description = "Referer header value Cloudfront passes to the S3 bucket"
#  value       = module.site.referer-header-value
#}

#---------
# DNS
#---------
output "dns-site-id" {
  description = "DNS Site ID"
  value       = module.site.dns-site-id
}

output "dns-site-alias" {
  description = "DNS Site Alias"
  value       = module.site.dns-site-alias
}

output "dns-site-name" {
  description = "DNS Site Name"
  value       = module.site.dns-site-name
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
