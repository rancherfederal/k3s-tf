resource "aws_lb" "this" {
  name                             = "${var.name}-k3s-controlplane"
  internal                         = var.internal
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = var.subnets

  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "owned"
  }, var.tags)
}

resource "aws_lb_listener" "server" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}

resource "aws_lb_target_group" "server" {
  name     = "${var.name}-k3s-server-tg"
  port     = var.port
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled  = true
    port     = var.port
    protocol = "TCP"
    matcher  = ""
    path     = ""
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({
    Name = "${var.name}-server-${var.port}"
  }, var.tags)
}
