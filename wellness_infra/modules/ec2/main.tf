# EC2 인스턴스를 위한 보안 그룹 설정
resource "aws_security_group" "ec2_sg" {
  name        = "${var.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  # SSH 접근 (보안을 위해 IP 제한 필요)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP 접근
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 포트 9000에 대한 접근 허용
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 포트 8001에 대한 접근 허용
  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-ec2-sg"
    Environment = var.environment
  }
}


# Amazon Linux 2 AMI를 SSM Parameter Store에서 가져오기
data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2 인스턴스 생성
resource "aws_instance" "this" {

  ami                    = data.aws_ssm_parameter.amazon_linux.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  # Setup EBS volume Size
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
  # User Data for Docker installation
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo chkconfig docker on
              EOF

  tags = {
    Name        = "${var.environment}-ec2"
    Environment = var.environment
  }
}

# Elastic IP allocation
resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-eip"
  }
}

# Associage Elastic IP with EC2 instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this.id
}