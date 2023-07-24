#------------------------------
# DNS
#------------------------------
# Create AWS Route 53 records if local.gandi_zone is false
resource "aws_route53_record" "site" {
  count   = local.gandi_zone == true ? 0 : 1
  zone_id = var.route53_zone_id
  name    = var.website_hostname
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site-validation" {
  for_each = {
    for option in aws_acm_certificate.site.domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    } if local.gandi_zone == false
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = var.route53_zone_id
  ttl             = 60
}

# Create Gandi LiveDNS records if local.gandi_zone is true
resource "gandi_livedns_record" "site" {
  count  = local.gandi_zone == true ? 1 : 0
  name   = local.hostname # Gandi doesn't store records fully qualified
  zone   = local.domain
  type   = "CNAME"
  ttl    = 600
  values = ["${aws_cloudfront_distribution.site.domain_name}."]
}

resource "gandi_livedns_record" "site-validation" {
  for_each = {
    for option in aws_acm_certificate.site.domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    } if local.gandi_zone == true
  }

  # Gandi doesn't store the records fully qualified so we trim the domain off
  name   = trimsuffix(each.value.name, ".${local.domain}.")
  zone   = local.domain
  ttl    = 600
  type   = each.value.type
  values = [each.value.record]
}
