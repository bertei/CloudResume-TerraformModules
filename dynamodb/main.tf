#Create Table (collection of Items (collection of attributes))
resource "aws_dynamodb_table" "main" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"

  #Define hash key (primary key) which allows you to point at Items and manipulate the table.
  hash_key = "Stat"
  attribute {
    name = "Stat"
    type = "S"
  }
}

#Create a Table's Item. I was able to create the attribute "Quantity" too via this way. But if I update the attribute, every time I tf plan, it will revert back the changes.
#Temporal fix by adding ignore_changes
resource "aws_dynamodb_table_item" "main" {
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  lifecycle {
    ignore_changes = [ item ]
  }
  item = <<ITEM
{
  "Stat": {"S": "view-count"}
}
ITEM

}