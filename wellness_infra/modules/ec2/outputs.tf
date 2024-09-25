output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "ec2_sg_id" {
  description = "EC2  ID"
  value       = aws_security_group.ec2_sg.id
}

output "elastic_ip" {
  description = "Elastic IP associated with the EC2 instance"
  value       = aws_eip.this.public_ip
}