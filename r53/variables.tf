variable "zone_id" {
  type = string
  default = ""
  description = "Hosted zone id"
}

variable "cdn_name" {
  type = string
  description = "CDN name"
}

# This is always the hosted zone ID when you create an alias record that routes traffic to a CloudFront distribution.
variable "cdn_zone_id" {
  type = string
  description = "CDN Zone ID"
  default = "Z2FDTNDATAQYW2"
}

