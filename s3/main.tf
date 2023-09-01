#locals {
#  enabled = var.create && var.bucket_name != "" && var.bucket_name != null
#}

resource "aws_s3_bucket" "main" {
  #count = local.enabled ? 1 : 0

  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}