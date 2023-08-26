locals {
  enabled = var.create && var.bucket_name != "" && var.bucket_name != null
}

resource "aws_s3_bucket" "main" {
  count = local.enabled ? 1 : 0

  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main[0].id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main[0].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main[0].id
  policy = data.aws_iam_policy_document.allow_bucket_read.json
}

data "aws_iam_policy_document" "allow_bucket_read" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.main[0].arn,
      "${aws_s3_bucket.main[0].arn}/*"
    ]
  }
}