output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "퍼블릭 서브넷들의 ID 리스트"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "프라이빗 서브넷들의 ID 리스트"
  value       = aws_subnet.private[*].id
}
