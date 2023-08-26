variable "create" {
  description = "Controls if S3 bucket should be created"
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Bucket name"
  type        = string
  default     = ""
}