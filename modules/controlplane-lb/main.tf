data "aws_vpc" "this" {
  id = var.vpc_id
}

#
# Classic Load Balancer Resources
#
resource "aws_elb" "this" {
  name                      = "${var.name}-k3s-controlplane"
  internal                  = var.internal
  subnets                   = var.subnets
  cross_zone_load_balancing = true
  security_groups           = [aws_security_group.lb.id]

  listener {
    instance_port     = var.port
    instance_protocol = "TCP"
    lb_port           = var.port
    lb_protocol       = "TCP"
  }

  health_check {
    target              = "TCP:${var.port}"
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.interval
    timeout             = var.timeout
  }

  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "owned"
  }, var.tags)
}

resource "aws_security_group" "lb" {
  name        = "${var.name}-k3s-controlplane-sg"
  vpc_id      = var.vpc_id
  description = "${var.name} controlplane"
}

resource "aws_security_group_rule" "ingress" {
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  type              = "ingress"

  cidr_blocks = [data.aws_vpc.this.cidr_block]
}

resource "aws_security_group_rule" "egress" {
  from_port         = -1
  to_port           = -1
  protocol          = "-1"
  security_group_id = aws_security_group.lb.id
  type              = "egress"

  cidr_blocks = ["0.0.0.0/0"]
}