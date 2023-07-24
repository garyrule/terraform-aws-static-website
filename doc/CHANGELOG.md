# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2023-07-24

### Added
- CloudFront Distribution
  - Custom error and root object variables
  - variables for custom_error_response
  - variables for cache policy
  - custom_header dynamic block
  - Viewer policy variable
  - Input for Lambda function association
  - Input for CloudFront function association
  - Input for Field Level Encryption Configuration
  - Input for real time log configuration
- S3
  - Input for custom S3 bucket policy
  - Inputs for S3 KMS key Server Side Encryption
- Input validations for all variables
- Additional examples
- Pin release version of release-on-push GitHub action
- LICENSE

### Changed
- Changed all outputs from dashed names to underscore
- Creating individual tf files for components
- Break up long lines for readability

### Fixed
- deploy-site.sh. Looked for wrong bucket name.

## [0.0.2] - 2023-07-17

### Added
- S3 Server Side Encryption Configuration
- CloudFront Standard Logging S3 bucket
- Updated default bucket policy for static assets that allows for s3:GetObjectVersion
- Update CloudFront cache handing to use a policy insead of forwarding_rules
- Added input validation for a number of variables
- Added documentation
- Updated diagram to reflect new logging bucket
- Added example html pages to test with

### Changed
- Input and output variable names
- Cleaned up deploy-site.sh a little
- Better examples

## [0.0.1] - 2023-07-13

### Added
- Initial Release of the module

[0.1.0]: https://github.com/garyrule/terraform-aws-static-website/releases/tag/v0.1.0
[0.0.2]: https://github.com/garyrule/terraform-aws-static-website/releases/tag/v0.0.2
[0.0.1]: https://github.com/garyrule/terraform-aws-static-website/releases/tag/v0.0.1
