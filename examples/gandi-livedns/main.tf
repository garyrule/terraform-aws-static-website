terraform {
  required_version = ">= 1.4.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

## Example using Gandi LiveDNS with all inputs
module "site" {
  source                            = "git::git@github.com:garyrule/tf_static_web.git?ref=master"
  dns_type                          = "gandi"
  region                            = "us-east-2"
  bucket_versioning                 = true
  cloudfront_price_class            = "PriceClass_100"
  cloudfront_viewer_security_policy = "TLSv1.2_2021"
  force_destroy_bucket              = true
  referer_header                    = "SuperS3cetSh4r3dKey!"
  website_hostname                  = var.website_hostname
  gandi_key                         = var.gandi_key
  gandi_sharing_id                  = var.gandi_sharing_id
}

