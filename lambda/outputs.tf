output "lambda_arn" {
  value = aws_lambda_function.main.arn
  description = "Lambda function ARN"
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.main.invoke_arn
  description = "Lambda invoke ARN"
}

output "lambda_function_name" {
  value = aws_lambda_function.main.function_name
  description = "Lambda Function Name"
}