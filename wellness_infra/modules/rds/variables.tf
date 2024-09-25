variable "environment" {
  description = "environment name (ex: dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where RDS instance is located"
  type        = list(string)
}

variable "db_user" {
  description = "RDS database username"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  type        = string
}

variable "db_port" {
  description = "Dataabase port"
  type        = number
  default     = 5432
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "ec2_security_group_id" {
  description = "Security group ID for the EC2 instance"
  type        = string
}