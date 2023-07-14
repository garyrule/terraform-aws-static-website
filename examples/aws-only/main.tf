terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
  }
}

# Minimal Route53 configuration. See README.me for more detailed example.
module "site" {
  source           = "git::git@github.com:garyrule/terraform-aws-static-website.git?ref=v0.0.2"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
}
