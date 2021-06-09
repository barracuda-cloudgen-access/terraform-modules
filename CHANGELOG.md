# Change Log

## v1.2.1

- [aws-asg] Update terraform versions.
- [aws-asg] Require mininum terraform version instead of forcing minor version.

## v1.2.0

All changes are compatible with the previous versions,
however upgrading an existing deploy will cause downtime.
This is the recommended upgrade process:

  1. Deploy new module using the same enrollment token from the existing one
  2. After checking the target groups are all healthy, update the CloudGen Access Proxy Host on the console
  3. Wait 15-30m to ensure all the clients updated the configuration
  4. Destroy the previous module

- [aws-asg] Update aws_elasticache_replication_group with new multi_az_enabled parameter
- [aws-asg] Use Amazon Linux 2 AMI as default AMI
- [aws-asg] Update naming
- [aws-asg] Allow multiple deploys on the same region
- [aws-asg] Allow specifying custom tags
- [aws-asg] Require terraform 0.14 to allow sensitive variables

## v1.1.0

- [aws-asg] Require terraform 0.13 to allow validations
- [aws-asg] Update README and misc logic
- [aws-asg] Allow using custom AMI
- [aws-asg] Add CloudWatch logs configuration
- [aws-asg] Add CloudGen Access Proxy log level configuration
- [aws-asg] Prevent lingering token after module removal
- [aws-asg] Create redis elasticache when instance count is more than 1
- [aws-asg] Recycle instances on launch configuration change

## v1.0.0

- [aws-asg] Initial release
