### Upload Static Assets to S3 Bucket

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
