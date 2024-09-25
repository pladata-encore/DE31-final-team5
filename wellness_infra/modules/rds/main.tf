# RDS Security group 
resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

# RDS Instance
resource "aws_db_instance" "this" {
  identifier             = "${var.environment}-db-instance-final"
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  instance_class         = var.instance_class
  username               = var.db_user
  password               = var.db_password
  port                   = var.db_port
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  tags = {
    Name        = "${var.environment}-db-final"
    Environment = var.environment
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-subnet-group-final"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group-final"
    Environment = var.environment
  }
}