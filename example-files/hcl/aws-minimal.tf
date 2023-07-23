terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
  }
}

module "site" {
  source           = "garyrule/static-website/aws"
  version          = "0.1.0"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
}
