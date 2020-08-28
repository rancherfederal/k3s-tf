locals {
  tags = merge({
    "Name"                                 = "${var.name}-nodepool",
    "kubernetes.io/cluster/${var.cluster}" = "owned"
  }, var.tags)

  shared_sgs = var.k3s_url == "" ? [data.aws_security_group.shared.id, data.aws_security_group.shared_server.id] : [data.aws_security_group.shared.id]
}

resource "aws_security_group" "this" {
  name        = "${var.name}-k3s-nodepool"
  vpc_id      = var.vpc_id
  description = "${var.name} node pool"
  tags        = local.tags
}

#
# Launch template
#
data "aws_security_group" "shared" {
  vpc_id = var.vpc_id
  name   = "${var.cluster}-k3s-shared-sg"
}

data "aws_security_group" "shared_server" {
  vpc_id = var.vpc_id
  name   = "${var.cluster}-k3s-shared-server-sg"
}

resource "aws_launch_template" "this" {
  name                   = "${var.name}-k3s-nodepool"
  image_id               = var.ami
  instance_type          = var.instance_type
  user_data              = data.template_cloudinit_config.this.rendered
  vpc_security_group_ids = concat([aws_security_group.this.id], local.shared_sgs, var.extra_vpc_security_group_ids)

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

# NOTE: This will only get attached to the ASG if we're dealing with a server
data "aws_lb" "controlplane" {
  name = "${var.cluster}-k3s-controlplane"
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name}-k3s-nodepool"
  vpc_zone_identifier = var.subnets

  min_size         = var.min
  max_size         = var.max
  desired_capacity = var.desired

  # Health check and target groups dependent on whether we're a server or not (identified via k3s_url)
  health_check_type = var.k3s_url == "" ? "ELB" : "EC2"
  load_balancers    = var.k3s_url == "" ? [data.aws_lb.controlplane.name] : []

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
