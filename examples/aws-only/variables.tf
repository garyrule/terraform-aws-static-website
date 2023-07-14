variable "website_hostname" {
  description = "Fully Qualified Domain Name for website"
  type        = string
}

variable "route53_zone_id" {
  description = "Zone ID of Route 53 Zone that we are using to host this website"
  type        = string
}
