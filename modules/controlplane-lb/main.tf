#
# Classic Load Balancer Resources
#
resource "aws_elb" "this_classic" {
  name                      = "${var.name}-k3s-controlplane"
  internal                  = var.internal
  subnets                   = var.subnets
  cross_zone_load_balancing = true

  listener {
    instance_port     = var.port
    instance_protocol = "TCP"
    lb_port           = var.port
    lb_protocol       = "TCP"
  }

  health_check {
    target              = "SSL:${var.port}"
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.internal
    timeout             = var.internal
  }

  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "owned"
  }, var.tags)
}
