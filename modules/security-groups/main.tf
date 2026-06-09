# ── ALB Security Group ──────────────────────────────────────────
# Faces the internet — allows HTTP and HTTPS from anywhere

resource "aws_security_group" "alb" {
  name = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
    Environment = var.environment
  }
}

# ── EC2 Security Group ──────────────────────────────────────────
# Only accepts traffic from the ALB — not from the internet directly
resource "aws_security_group" "ec2" {
  name = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from ALB only"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
    Environment = var.environment
  }
}

# ── RDS Security Group ──────────────────────────────────────────
# Only accepts traffic from EC2 — database is never publicly accessible

resource "aws_security_group" "rds" {
  name = "${var.project_name}-rds-sg"
  description = "Security group for RDS database"
  vpc_id = var.vpc_id

  ingress {
    description = "MySQL from EC2 only"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "All outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
    Environment = var.environment
  }
}