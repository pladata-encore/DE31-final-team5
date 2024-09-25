resource "aws_dynamodb_table" "terraform_lock" {
  name         = "${var.environment}-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  lifecycle {
    prevent_destroy = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
  # tag
  tags = {
    Name        = "Terraform Lock Table"
    Environment = var.environment
  }
}