#
# Prefix
#

resource "random_string" "prefix" {
  length  = 6
  lower   = true
  upper   = true
  number  = true
  special = false
}

#
# Enrollment token
#

resource "aws_secretsmanager_secret" "token" {
  name                    = "cga_proxy_${random_string.prefix.result}_enrollment_token"
  description             = "CloudGen Access Proxy Enrollment Token"
  recovery_window_in_days = 0

  tags = {
    Name = "cga_proxy_${random_string.prefix.result}_enrollment_token"
  }
}

resource "aws_secretsmanager_secret_version" "token" {
  secret_id     = aws_secretsmanager_secret.token.id
  secret_string = var.cloudgen_access_proxy_token
}

#
# NLB
#

resource "aws_lb" "nlb" {
  enable_cross_zone_load_balancing = var.nlb_enable_cross_zone_load_balancing
  internal                         = false #tfsec:ignore:AWS005
  load_balancer_type               = "network"
  name_prefix                      = "cga-"
  subnets                          = var.nlb_subnets

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.cloudgen_access_proxy_public_port
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
  name_prefix          = "cga-"
  port                 = var.cloudgen_access_proxy_public_port
  protocol             = "TCP"
  vpc_id               = data.aws_subnet.vpc_from_first_subnet.vpc_id

  health_check {
    interval          = 30
    port              = var.cloudgen_access_proxy_public_port
    protocol          = "TCP"
    healthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}

#
# Security Groups
#

# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
# You cannot allow traffic from clients to targets through the load balancer using the security groups for the clients in the security groups for the targets.
# Use the client CIDR blocks in the target security groups instead.
resource "aws_security_group" "inbound" {
  name        = "cga-proxy-${random_string.prefix.result}-inbound"
  description = "Inbound traffic for CloudGen Access Proxy"
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

  tags = {
    Name = "cga-proxy-${random_string.prefix.result}-inbound"
  }
}

resource "aws_security_group" "resources" {
  name        = "cga-proxy-${random_string.prefix.result}-resources"
  description = "Use this group to allow CloudGen Access Proxy to access internal resources"
  vpc_id      = data.aws_subnet.vpc_from_first_subnet.vpc_id

  tags = {
    Name = "cga-proxy-${random_string.prefix.result}-resources"
  }
}

resource "aws_security_group" "redis" {
  count = local.redis_enabled ? 1 : 0

  name        = "cga-proxy-${random_string.prefix.result}-redis"
  description = "Used to allow CloudGen Access proxy to redis"
  vpc_id      = data.aws_subnet.vpc_from_first_subnet.vpc_id

  tags = {
    Name = "cga-proxy-${random_string.prefix.result}-redis"
  }
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
        "value"               = aws_launch_configuration.launch_config.name
        "propagate_at_launch" = true
      },
    ],
    local.common_tags_asg
  )
}

#
# AMI
#

data "aws_ami" "ami" {
  count = var.asg_ami == "amazonlinux2" ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}

#
# Launch Configuration
#

resource "aws_launch_configuration" "launch_config" {
  associate_public_ip_address = var.launch_cfg_associate_public_ip_address
  iam_instance_profile        = aws_iam_instance_profile.profile.id
  image_id                    = coalesce(data.aws_ami.ami[0].id, var.asg_ami)
  instance_type               = var.launch_cfg_instance_type
  key_name                    = var.launch_cfg_key_pair_name
  name_prefix                 = "cga-proxy-${random_string.prefix.result}-"
  security_groups = compact([
    aws_security_group.inbound.id,
    aws_security_group.resources.id,
    local.redis_enabled ? aws_security_group.redis[0].id : ""
  ])
  user_data = <<-EOT
  #!/bin/bash
  %{~if var.cloudwatch_logs_enabled~}
  # Install CloudWatch Agent
  curl -sL "https://url.fyde.me/config-ec2-cloudwatch-logs" | bash -s -- \
    -l "${aws_cloudwatch_log_group.cloudgen_access_proxy[0].name}" \
    -r "${var.aws_region}"
  %{~endif~}
  # Install CloudGen Access Proxy
  curl -sL "https://url.fyde.me/proxy-linux" | bash -s -- \
    -u \
  %{~if local.redis_enabled~}
    -r "${aws_elasticache_replication_group.redis[0].primary_endpoint_address}" \
    -s "${aws_elasticache_replication_group.redis[0].port}" \
  %{~endif~}
    -p "${var.cloudgen_access_proxy_public_port}" \
    -l "${var.cloudgen_access_proxy_level}" \
    -e "FYDE_PREFIX=cga_proxy_${random_string.prefix.result}_"
  # Harden instance and reboot
  curl -sL "https://url.fyde.me/harden-linux" | bash -s --
  shutdown -r now
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
  name = "cga-proxy-${random_string.prefix.result}-profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name        = "cga-proxy-${random_string.prefix.result}-role"
  description = "Role used for the CloudGen Access Proxy instances"
  path        = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AssumeRole"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "cga-proxy-${random_string.prefix.result}-role"
  }
}

resource "aws_iam_role_policy" "cloudgen_access_proxy_secrets" {
  name = "cga-proxy-${random_string.prefix.result}-secrets"
  role = aws_iam_role.role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GetSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:cga_proxy_${random_string.prefix.result}_*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  count = var.cloudwatch_logs_enabled ? 1 : 0

  name = "cga-proxy-${random_string.prefix.result}-cloudwatch-logs"
  role = aws_iam_role.role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudgen_access_proxy[0].arn}:*"
      },
      {
        Sid    = "CloudWatchLogStreams"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "redis" {
  count = local.redis_enabled ? 1 : 0

  name = "cga-proxy-${random_string.prefix.result}-redis"
  role = aws_iam_role.role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DiscoverRedisCluster"
        Effect = "Allow"
        Action = [
          "elasticache:DescribeCacheClusters"
        ]
        Resource = "arn:aws:elasticache:${var.aws_region}:${data.aws_caller_identity.current.account_id}:replicationgroup:${aws_elasticache_replication_group.redis[0].id}"
      }
    ]
  })
}

#
# CloudWatch
#

resource "aws_cloudwatch_log_group" "cloudgen_access_proxy" {
  count = var.cloudwatch_logs_enabled ? 1 : 0

  name              = "/aws/ec2/cga-proxy-${random_string.prefix.result}"
  retention_in_days = var.cloudWatch_logs_retention_in_days

  tags = {
    Name = "/aws/ec2/cga-proxy-${random_string.prefix.result}"
  }
}

#
# Redis
#

resource "aws_elasticache_replication_group" "redis" {
  count = local.redis_enabled ? 1 : 0

  automatic_failover_enabled    = true
  engine                        = "redis"
  replication_group_id          = "cga-proxy-${random_string.prefix.result}"
  replication_group_description = "Redis for CloudGen Access Proxy"
  node_type                     = "cache.t2.micro"
  number_cache_clusters         = 2
  subnet_group_name             = aws_elasticache_subnet_group.redis[0].name
  security_group_ids            = [aws_security_group.redis[0].id]
  port                          = 6379
  at_rest_encryption_enabled    = false #tfsec:ignore:AWS035
  transit_encryption_enabled    = false #tfsec:ignore:AWS036
  multi_az_enabled              = true

  tags = {
    Name = "cga-proxy-${random_string.prefix.result}"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  count = local.redis_enabled ? 1 : 0

  name        = "cga-proxy-${random_string.prefix.result}"
  description = "Redis Subnet Group for CloudGen Access Proxy"
  subnet_ids  = coalescelist(var.redis_subnets, var.asg_subnets)

  tags = {
    Name = "cga-proxy-${random_string.prefix.result}"
  }
}
