resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "main" {
    bucket = aws_s3_bucket.main.id
    
    #Every update to a file creates a new version of that file with versioning
    versioning_configuration {
        status = "Enabled"
    }
}