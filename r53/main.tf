resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = "bernatei.com"
  type    = "A"
  alias {
    name                    = var.cdn_name
    zone_id                 = var.cdn_zone_id
    evaluate_target_health  = false
  }
}