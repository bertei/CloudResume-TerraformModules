variable "domain_name" {
  type = any
}

variable "acm_arn" {
  type = any
}

variable "bucket_id" {
  type = any
}

variable "bucket_arn" {
  type = any
}

variable "custom_error_response" {
  type = any
  default = []
  description = "One or more custom error response."
}