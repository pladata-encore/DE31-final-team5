variable "environment" {
  description = "환경 이름 (예: dev, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
}

variable "subnet_id" {
  description = "EC2 인스턴스를 생성할 서브넷 ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "key_name" {
  description = "EC2 인스턴스에 사용할 SSH 키 페어 이름"
  type        = string
}
