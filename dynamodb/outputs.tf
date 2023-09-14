output "table_arn" {
  value = aws_dynamodb_table.main.arn
  description = "Table arn"
}