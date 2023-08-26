output "bucket_arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.main.*.arn
  #value       = aws_s3_bucket.main[0].arn
}

output "bucket_domain" {
  description = "Domain name of the bucket"
  value       = aws_s3_bucket_website_configuration.main.*.website_domain
}