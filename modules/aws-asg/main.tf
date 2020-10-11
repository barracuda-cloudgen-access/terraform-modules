#
# Enrollment token
#

resource "aws_secretsmanager_secret" "token" {
  name                    = "fyde_enrollment_token"
  description             = "Fyde Access Proxy Enrollment Token"
  recovery_window_in_days = 0

  tags = local.common_tags_map
}

resource "aws_secretsmanager_secret_version" "token" {
  secret_id     = aws_secretsmanager_secret.token.id
  secret_string = var.fyde_access_proxy_token
}

#
# NLB
#

resource "aws_lb" "nlb" {
  enable_cross_zone_load_balancing = var.nlb_enable_cross_zone_load_balancing
  internal                         = false #tfsec:ignore:AWS005
  load_balancer_type               = "network"
  name_prefix                      = "fyde-"
  subnets                          = var.nlb_subnets

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      "Name" = "fyde-access-proxy"
    },
    local.common_tags_map
  )
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.fyde_access_proxy_public_port
  protocol          = "TCP"

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "nlb_target_group" {
  deregistration_delay = 60
  name_prefix          = "fyde-"
  port                 = var.fyde_access_proxy_public_port
  protocol             = "TCP"
  vpc_id               = data.aws_subnet.vpc_from_first_subnet.vpc_id

  health_check {
    interval          = 30
    port              = var.fyde_access_proxy_public_port
    protocol          = "TCP"
    healthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      "Name" = "fyde-access-proxy"
    },
    local.common_tags_map
  )
}

#
# Security Groups
#

# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
# You cannot allow traffic from clients to targets through the load balancer using the security groups for the clients in the security groups for the targets.
# Use the client CIDR blocks in the target security groups instead.
resource "aws_security_group" "inbound" {
  name        = "fyde-access-proxy-inbound"
  description = "Inbound traffic for Fyde Access Proxy"
  vpc_id      = data.aws_subnet.vpc_from_first_subnet.vpc_id

  ingress {
    description = "Inbound from All"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS008
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }

  tags = merge(
    {
      "Name" = "fyde-access-proxy-inbound"
    },
    local.common_tags_map
  )
}

resource "aws_security_group" "resources" {
  name        = "fyde-access-proxy-resources"
  description = "Use this group to allow Fyde Access Proxy access to internal resources"
  vpc_id      = data.aws_subnet.vpc_from_first_subnet.vpc_id

  tags = merge(
    {
      "Name" = "fyde-access-proxy-resources"
    },
    local.common_tags_map
  )
}

resource "aws_security_group" "redis" {
  count = local.redis_enabled ? 1 : 0

  name        = "fyde-access-proxy-redis"
  description = "Used to allow FydeAccessProxy access to redis"
  vpc_id      = data.aws_subnet.vpc_from_first_subnet.vpc_id

  tags = merge(
    {
      "Name" = "fyde-access-proxy-redis"
    },
    local.common_tags_map
  )
}

resource "aws_security_group_rule" "redis" {
  count = local.redis_enabled ? 1 : 0


  description       = "Allow ingress to redis port from group members"
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.redis[0].id
}

#
# Auto Scaling Group
#

resource "aws_autoscaling_group" "asg" {
  default_cooldown          = 120
  desired_capacity          = var.asg_desired_capacity
  force_delete              = true
  health_check_grace_period = 60
  health_check_type         = "ELB"
  launch_configuration      = aws_launch_configuration.launch_config.id
  max_size                  = var.asg_max_size
  metrics_granularity       = "1Minute"
  min_size                  = var.asg_min_size
  name                      = aws_launch_configuration.launch_config.name
  target_group_arns         = [aws_lb_target_group.nlb_target_group.arn]
  termination_policies      = ["OldestInstance"]
  vpc_zone_identifier       = var.asg_subnets
  wait_for_capacity_timeout = "10m"
  protect_from_scale_in     = false

  lifecycle {
    create_before_destroy = true
  }

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "fyde-access-proxy"
        "propagate_at_launch" = true
      },
    ],
    local.common_tags_asg,
  )
}

#
# AMI
#

data "aws_ami" "fyde_access_proxy" {
  count = var.asg_ami == "fyde" ? 1 : 0

  most_recent = true

  filter {
    name   = "name"
    values = ["amazonlinux-2-base_*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["766535289950"]
}

#
# Launch Configuration
#

resource "aws_launch_configuration" "launch_config" {
  associate_public_ip_address = var.launch_cfg_associate_public_ip_address
  iam_instance_profile        = aws_iam_instance_profile.profile.id
  image_id                    = coalesce(data.aws_ami.fyde_access_proxy[0].id, var.asg_ami)
  instance_type               = var.launch_cfg_instance_type
  key_name                    = var.launch_cfg_key_pair_name
  name_prefix                 = "fyde-access-proxy-"
  security_groups = compact([
    aws_security_group.inbound.id,
    aws_security_group.resources.id,
    local.redis_enabled ? aws_security_group.redis[0].id : ""
  ])
  user_data = <<-EOT
  #!/bin/bash
  set -xeuo pipefail
  echo "RateLimitBurst=10000" >> /etc/systemd/journald.conf
  systemctl restart systemd-journald.service
  %{~if var.cloudwatch_logs_enabled~}
  curl -sL "https://url.fyde.me/config-ec2-cloudwatch-logs" | bash -s -- \
    -l "/aws/ec2/FydeAccessProxy" \
    -r "${var.aws_region}"
  %{~endif~}
  curl -sL "https://url.fyde.me/install-fyde-proxy-linux" | bash -s -- \
    -u \
  %{~if local.redis_enabled~}
    -r "${aws_elasticache_replication_group.redis[0].primary_endpoint_address}" \
    -s "${aws_elasticache_replication_group.redis[0].port}" \
  %{~endif~}
    -p "${var.fyde_access_proxy_public_port}" \
    -l "${var.fyde_proxy_level}"
  EOT

  root_block_device {
    delete_on_termination = true
    encrypted             = false #tfsec:ignore:AWS014
  }

  lifecycle {
    create_before_destroy = true
  }
}

#
# Notifications
#

resource "aws_autoscaling_notification" "notification" {
  count = var.asg_notification_arn_topic == "" ? 0 : 1

  group_names = [
    aws_autoscaling_group.asg.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = var.asg_notification_arn_topic
}

#
# IAM
#

resource "aws_iam_instance_profile" "profile" {
  name = "fyde-access-proxy-profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name        = "fyde-access-proxy-role"
  description = "Role used for the Fyde Access Proxy instances"
  path        = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "",
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        }
    }]
}
EOF
}

resource "aws_iam_role_policy" "fyde_secrets" {
  name = "fyde-access-proxy-fyde-secrets"
  role = aws_iam_role.role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GetFydeSecrets",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:fyde_*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  count = var.cloudwatch_logs_enabled ? 1 : 0

  name = "fyde-access-proxy-cloudwatch-logs"
  role = aws_iam_role.role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchLogGroup",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "${aws_cloudwatch_log_group.fyde_access_proxy[0].arn}"
    },
    {
      "Sid": "CloudWatchLogStreams",
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "redis" {
  count = local.redis_enabled ? 1 : 0

  name = "fyde-access-proxy-redis"
  role = aws_iam_role.role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DiscoverRedisCluster",
      "Effect": "Allow",
      "Action": [
        "elasticache:DescribeCacheClusters"
      ],
      "Resource": "arn:aws:elasticache:${var.aws_region}:${data.aws_caller_identity.current.account_id}:replicationgroup:${aws_elasticache_replication_group.redis[0].id}"
    }
  ]
}
EOF
}

#
# CloudWatch
#

resource "aws_cloudwatch_log_group" "fyde_access_proxy" {
  count = var.cloudwatch_logs_enabled ? 1 : 0

  name              = "/aws/ec2/FydeAccessProxy"
  retention_in_days = var.cloudWatch_logs_retention_in_days

  tags = local.common_tags_map
}

#
# Redis
#

resource "aws_elasticache_replication_group" "redis" {
  count = local.redis_enabled ? 1 : 0

  automatic_failover_enabled    = true
  engine                        = "redis"
  replication_group_id          = "FydeAccessProxy"
  replication_group_description = "Redis for Fyde Access Proxy"
  node_type                     = "cache.t2.micro"
  number_cache_clusters         = 2
  subnet_group_name             = aws_elasticache_subnet_group.redis[0].name
  security_group_ids            = [aws_security_group.redis[0].id]
  port                          = 6379
  at_rest_encryption_enabled    = false #tfsec:ignore:AWS035
  transit_encryption_enabled    = false #tfsec:ignore:AWS036

  tags = local.common_tags_map
}

resource "aws_elasticache_subnet_group" "redis" {
  count = local.redis_enabled ? 1 : 0

  name        = "FydeAccessProxy"
  description = "Redis Subnet Group for Fyde Access Proxy"
  subnet_ids  = coalescelist(var.redis_subnets, var.asg_subnets)
}

# Workaround until https://github.com/terraform-providers/terraform-provider-aws/pull/13909 is merged
# From https://github.com/terraform-providers/terraform-provider-aws/issues/13706#issuecomment-704331694
resource "null_resource" "redis_multiaz_enable" {
  count = local.redis_enabled ? 1 : 0

  triggers = {
    cache = aws_elasticache_replication_group.redis[0].id
  }
  provisioner "local-exec" {
    command = "aws elasticache modify-replication-group --replication-group-id ${aws_elasticache_replication_group.redis[0].id} --multi-az-enabled --apply-immediately"
  }
}
