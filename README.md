# Barracuda CloudGen Access - Terraform Modules

![Barracuda CloudGen Access](./misc/cga-logo.png)

Terraform modules for CloudGen Access resources

Visit the [Website](https://www.barracuda.com/products/cloudgen-access)

Check the [Product Documentation](https://campus.barracuda.com/product/cloudgenaccess/doc/93201218/overview/)

## Modules

- [CloudGen Access Proxy ASG](./modules/aws-asg/)

## Misc

- This repository has [pre-commit](https://github.com/antonbabenko/pre-commit-terraform) configured
  - Test all the pre-commit hooks with:
    - `docker run -v $(pwd):/lint -w /lint ghcr.io/antonbabenko/pre-commit-terraform:latest run -a`
    - Cleanup, in case of plugin issues: `find . -name ".terraform*" -print0 | xargs -0 rm -r`
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
