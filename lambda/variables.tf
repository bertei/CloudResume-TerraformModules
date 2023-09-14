variable "lambda_role_name" {
  type = string
  description = "Lambda role name"
}

variable "lambda_function_name" {
  type = string
  description = "Lambda function name"
}

variable "table_arn" {
  type = string
  description = "Necessary for the policy. It's defined based on an output from the dynamodb module"
}