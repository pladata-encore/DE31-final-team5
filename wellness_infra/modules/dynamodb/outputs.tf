output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for terraform state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}
