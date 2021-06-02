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

  common_tags_asg = null_resource.tags_as_list_of_maps.*.triggers
}

resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(local.common_tags_map))

  triggers = {
    "key"                 = keys(local.common_tags_map)[count.index]
    "value"               = values(local.common_tags_map)[count.index]
    "propagate_at_launch" = true
  }
}
