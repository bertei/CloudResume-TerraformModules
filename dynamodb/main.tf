resource "aws_dynamodb_table" "main" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "Stat"
  attribute {
    name = "Stat"
    type = "S"
  }
}

##Everytime I run tf plan, it restarts Quantity attribute to 0. Not good if i'm updating the 'view-counter'.
##Probably i'll create the attribute manually.
#resource "aws_dynamodb_table_item" "main" {
#  table_name = aws_dynamodb_table.main.name
#  hash_key   = aws_dynamodb_table.main.hash_key
#
#  item = <<ITEM
#{
#  "Stat": {"S": "view-count"},
#  "Quantity": {"N": "0"}
#}
#ITEM
#}