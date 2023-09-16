# This data source looks up the public DNS zone
data "aws_route53_zone" "public" {
  name         = "bernatei.com"
  private_zone = false
}

resource "aws_acm_certificate" "main" {
  domain_name       = "bernatei.com"
  validation_method = "DNS" 
  subject_alternative_names = ["bernatei.com", "*.bernatei.com"]
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.public.id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.main.arn
}