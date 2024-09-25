output "app_bucket_name" {
  description = "The name of the app S3 bucket"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "terraform_state_bucket_name" {
  description = "The name of the terraform state S3 bucket"
  value       = aws_s3_bucket.terraform_state_bucket.bucket
}
