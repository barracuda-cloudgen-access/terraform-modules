# Barracuda CloudGen Access - Terraform Modules

![Barracuda CloudGen Access](./misc/cga-logo.png)

Terraform modules for CloudGen Access resources

Visit the [Website](https://www.barracuda.com/products/cloudgen-access)

Check the [Product Documentation](https://campus.barracuda.com/product/cloudgenaccess/doc/93201218/overview/)

## Access Proxy

### AWS - Auto Scaling Group

Usage example:

```yaml
module "fyde-access-proxy" {
  source = "git::git@github.com/barracuda-cloudgen-access/terraform-modules.git//modules/aws-asg?ref=v1.1.0"

  # Fyde Access Proxy
  fyde_access_proxy_public_port = 443
  fyde_access_proxy_token       = "replace_with_token"

  # AWS
  aws_region = "us-east-1"

  # Network Load Balancing
  nlb_subnets = ["subnet-public-1", "subnet-public-2", "subnet-public-3"]

  # Auto Scaling Group
  asg_desired_capacity    = 3
  asg_min_size            = 3
  asg_max_size            = 3
  asg_subnets             = ["subnet-private-1", "subnet-private-2", "subnet-private-3"]

  # Launch Configuration
  launch_cfg_instance_type = "t2.small"
  launch_cfg_key_pair_name = "key_pair_name"
}

output "Network_Load_Balancer_DNS_Name" {
  value       = module.fyde-access-proxy.Network_Load_Balancer_DNS_Name
}

output "Security_Group_for_Resources" {
  value       = module.fyde-access-proxy.Security_Group_for_Resources
}
```

Check all the available variables [here](modules/aws-asg/README.md)

## Misc

- This repository has [pre-commit](https://github.com/antonbabenko/pre-commit-terraform) configured
  - Test all the pre-commit hooks with `pre-commit run -a`
- Test branch with `git::git@github.com:fyde/terraform-modules.git//modules/aws-asg?ref=<branch-name>`
- Test github actions with [nektos/act](https://github.com/nektos/act)

## Links

- More deploy options:
  - [AWS Templates](https://github.com/barracuda-cloudgen-access/aws-templates)
  - [Azure Templates](https://github.com/barracuda-cloudgen-access/azure-templates)
  - [Helm Charts](https://github.com/barracuda-cloudgen-access/helm-charts)

## License

Licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0), a OSI-approved license.

## Disclaimer

All of the source code on this repository is provided "as is", without warranty of any kind,
express or implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose and noninfringement. in no event shall Barracuda be liable for any claim,
damages, or other liability, whether in an action of contract, tort or otherwise, arising from,
out of or in connection with the source code.
