resource "aws_security_group" "this" {
  name        = "${var.name}-k3s"
  description = "${var.name} k3s db sg"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-k3s"
  subnet_ids = var.subnets

  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "owned"
  }, var.tags)
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-k3s"

  engine         = "mysql"
  engine_version = "5.7"

  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  storage_type           = "gp2"
  ca_cert_identifier     = var.ca_cert_identifier
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  instance_class       = var.instance_class
  name                 = "k3s"
  username             = var.username
  password             = var.password
  parameter_group_name = "default.mysql5.7"

  backup_retention_period      = 0
  delete_automated_backups     = true
  skip_final_snapshot          = true
  performance_insights_enabled = false
  apply_immediately            = true

  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "owned"
  }, var.tags)
}