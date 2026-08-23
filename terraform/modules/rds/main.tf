resource "aws_db_subnet_group" "this" {
  name = "${var.project_name}-${var.environment}-postgres"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-postgres"
  }
}

resource "aws_security_group" "postgres" {
  name        = "${var.project_name}-${var.environment}-postgres-sg"
  description = "Controls access to the Backstage PostgreSQL database."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-postgres-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  for_each = var.allowed_security_group_ids

  security_group_id = aws_security_group.postgres.id

  referenced_security_group_id = each.value

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "PostgreSQL access from approved EKS security group"
}

resource "aws_vpc_security_group_egress_rule" "postgres" {
  security_group_id = aws_security_group.postgres.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow outbound traffic"
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  engine = "postgres"

  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.master_username

  manage_master_user_password = true

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.postgres.id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = var.backup_retention_period

  copy_tags_to_snapshot = true

  deletion_protection = false
  skip_final_snapshot = true

  auto_minor_version_upgrade = true

  apply_immediately = true

  tags = {
    Name = "${var.project_name}-${var.environment}-postgres"
  }
}
