output "bucket_arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.main.arn
  #value       = aws_s3_bucket.main[0].arn
}

output "bucket_id" {
  description = "ID of the bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_regional_domain_name" {
  description = "The bucket domain name including the region name."
  value = aws_s3_bucket.main.bucket_regional_domain_name
}