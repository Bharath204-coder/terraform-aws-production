# Subnet group — tells RDS which subnets it can use
# Needs subnets in at least 2 AZs for Multi-AZ support

resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name  = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

# RDS MySQL instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class
  allocated_storage = 20

  db_name = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]

  multi_az = false

  storage_encrypted = true

  deletion_protection = false

  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-db"
    Environment = var.environment
  }
}