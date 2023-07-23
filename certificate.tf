#------------------------------
# ACM Certificate
#------------------------------
resource "aws_acm_certificate" "site" {
  provider          = aws.use1
  domain_name       = var.website_hostname
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = local.tags
}

# We'll use either Gandi or AWS records depending on the value of local.gandi_zone.
resource "aws_acm_certificate_validation" "site-aws" {
  provider                = aws.use1
  count                   = local.gandi_zone == true ? 0 : 1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in aws_route53_record.site-validation : record.fqdn]
}

resource "aws_acm_certificate_validation" "site-gandi" {
  provider        = aws.use1
  count           = local.gandi_zone == true ? 1 : 0
  certificate_arn = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in gandi_livedns_record.site-validation
  : "${record.name}.${local.domain}"]
}
