locals {
  tags = merge({
    "Name"                                 = "${var.name}-nodepool",
    "kubernetes.io/cluster/${var.cluster}" = "owned"
  }, var.tags)
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-k3s-nodepool"
  vpc_id      = var.vpc_id
  description = "${var.name} node pool"
  tags        = local.tags
}

resource "aws_security_group_rule" "all_egress" {
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

#
# Launch template
#
data "aws_security_group" "shared" {
  vpc_id = var.vpc_id
  name   = "${var.cluster}-k3s-shared-sg"
}

resource "aws_launch_template" "this" {
  name                   = "${var.name}-k3s-nodepool"
  image_id               = var.ami
  instance_type          = var.instance_type
  user_data              = data.template_cloudinit_config.this.rendered
  vpc_security_group_ids = concat([aws_security_group.this.id], [data.aws_security_group.shared.id], var.extra_vpc_security_group_ids)

  //  dynamic "block_device_mappings" {
  //    for_each = var.block_device_mappings
  //
  //    content {
  //      device_name = lookup(block_device_mappings.value, "device_name", "/dev/sda1")
  //      ebs {
  //        volume_size           = lookup(block_device_mappings.value, "volume_size", 32)
  //        encrypted             = lookup(block_device_mappings.value, "encrypted", false)
  //        delete_on_termination = lookup(block_device_mappings.value, "delete_on_termination", true)
  //      }
  //    }
  //  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != "" ? [var.iam_instance_profile] : []
    content {
      name = iam_instance_profile.value
    }
  }

  tags = local.tags
}

#
# Autoscaling group
#
data "aws_lb_target_group" "controlplane" {
  name = "${var.cluster}-k3s-server-tg"
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name}-k3s-nodepool"
  vpc_zone_identifier = var.subnets

  min_size         = var.min
  max_size         = var.max
  desired_capacity = var.desired

  health_check_type = "EC2"
  target_group_arns = data.aws_lb_target_group.controlplane.arn

  dynamic "launch_template" {
    for_each = var.spot ? [] : ["spot"]

    content {
      id      = aws_launch_template.this.id
      version = "$Latest"
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = var.spot ? ["spot"] : []

    content {
      instances_distribution {
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 0
      }

      launch_template {
        launch_template_specification {
          launch_template_id   = aws_launch_template.this.id
          launch_template_name = aws_launch_template.this.name
          version              = "$Latest"
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = local.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
