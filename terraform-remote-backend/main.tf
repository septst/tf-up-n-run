provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "my-tf-up-and-running-state"

  # Prevents accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning so you can see the full revision history of your
# state files
resource "aws_s3_bucket_versioning" "enable_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default_encryption_config" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "block_all_public_access" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_locks" {
    name         = "my-tf-up-and-running-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

# terraform {
#   backend "s3" {
#     bucket         = "my-tf-up-and-running-state"
#     key            = "global/s3/terraform.tfstate"
#     region         = "us-east-2"

#     dynamodb_table = "my-tf-up-and-running-locks"
#     encrypt        = true
#   }
# }