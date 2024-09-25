variable "environment" {
  description = " environment name (ex: dev, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "key_name" {
  description = "SSH Key pair name using EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "db_user" {
  description = "RDS database username"
  type        = string
}

variable "db_password" {
  type = string
}

