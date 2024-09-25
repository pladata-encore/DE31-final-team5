# VPC 관련 출력
output "vpc_id" {
  description = "create VPC ID"
  value       = module.vpc.vpc_id
}

# EC2 관련 출력
output "ec2_instance_id" {
  description = "create EC2 instance's ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "create EC2 instance's public IP"
  value       = module.ec2.instance_public_ip
}