## Instructions

### Create Input Variables
 Create `terraform.tfvars` with the required input variables

##### Set the hostname for the website
* `website_hostname`

##### AWS Route 53
* `route53_zone_id`

##### Gandi LiveDNS
* `dns_type` set to "gandi"
* `gandi_key`

### Edit Configuration - Optional
Edit `main.tf` and change inputs to match your requirements.

See [Example](#examples) for more information.

### Deploy Website
#### Initialize terraform

`$ terraform init`

#### Create the plan

`$ terraform plan -var-file terraform.tfvars -out tfplan.out`

#### Apply the plan

`$ terraform apply tfplan.out`

### Static Assets
This module does not sync static assets for you.
See [Static Assets](doc/STATIC_ASSETS.md) for more information.
