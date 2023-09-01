output "cdn_name" {
  description = "CDN Domain name"
  value = aws_cloudfront_distribution.main.domain_name
}