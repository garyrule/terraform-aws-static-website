terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }
  }
}

## Example All-AWS w/ mimimum inputs
module "site" {
  #source           = "git::git@github.com:garyrule/terraform-aws-static-website.git?ref=master"
  source           = "../../"
  route53_zone_id  = var.route53_zone_id
  website_hostname = var.website_hostname
}
