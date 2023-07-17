## Instructions

#### Create Input Variables
 Create `terraform.tfvars` with the required input variables

#### Set the hostname for the website
* `website_hostname`

#### Configure DNS Variables

##### AWS Route 53
* `route53_zone_id`

#### Gandi LiveDNS
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

### Upload Static Assets
Upload static assets to S3 bucket.

This module does not sync static assets for you.
There is an example script included that will do so, but it's assumed that you'll
work out deploying the static assets independent of this module.

#### Use include example script
* It will determine the static asset bucket name and CloudFront
distribution from the terraform output.
* If `website_bucket_versioning` is disabled, it will also invalidate CloudFront cache.

From one of the example directories:

```shell
$ ../../example-files/bin/deploy-site.sh -s htdocs
````
