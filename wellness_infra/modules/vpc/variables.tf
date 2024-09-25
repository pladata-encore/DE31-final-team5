variable "environment" {
  description = "환경 이름 (예: dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  type        = string
}
