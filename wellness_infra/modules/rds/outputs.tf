output "db_endpoint" {
  description = "RDS instance's endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  description = "RDS instace ID"
  value       = aws_db_instance.this.id
}