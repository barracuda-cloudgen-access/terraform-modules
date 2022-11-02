#
# Locals
#

locals {

  redis_enabled = var.asg_desired_capacity > 1 ? true : false

  common_tags_map = merge(
    {
      application      = "cloudgen-access-proxy"
      "module_version" = var.module_version
      "disclaimer"     = "Created by terraform"
    },
    var.tags
  )
}
