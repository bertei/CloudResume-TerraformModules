## IAM-Resources ##
#Trust relation ship policy, so Lambda service can assume 'ViewCounter-Role' permissions.
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#DynamoDB policy, so Lambda-role can RW into the DynamoDB Table.
data "aws_iam_policy_document" "dynamodb_table_permissions" {
  statement {
    sid = "AllowRWViewCounterTable"

    #principals {
    #  type = "Service"
    #  identifiers = [".amazonaws.com"]
    #}

    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable",
      "dynamodb:PutItem",
      "dynamodb:GetItem"
    ]

    resources = [
      "${var.table_arn}"
    ]
  }
}

resource "aws_iam_policy" "ddbtable_permission_policy" {
  name        = "ddb_table_permission"
  path        = "/"
  description = "IAM policy for dynamodb table rw permission"
  policy      = data.aws_iam_policy_document.dynamodb_table_permissions.json
}

resource "aws_iam_role_policy_attachment" "ddbtable_policy_attachment" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.ddbtable_permission_policy.arn
}

#Cloudwatch logs policy, allows Lambda-role to create log groups/streams.
data "aws_iam_policy_document" "lambda_logging_document" {
  statement {
    effect = "Allow"
    sid = "AllowCWLogGroup"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.main.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda into cloudwatch logs"
  policy      = data.aws_iam_policy_document.lambda_logging_document.json
}

resource "aws_iam_role_policy_attachment" "logging_policy_attachment" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

#Creates 'ViewCounter-Role'
resource "aws_iam_role" "main" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


## CloudWatch ##
#Creates Cloudwatch logs for the lambda
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 0
}

## Lambda ##

#Generates an archive from a file. Lambda.py to a .zip file.
data "archive_file" "main" {
  type        = "zip"
  source_file = "lambda-viewcounter.py"
  output_path = "lambda-viewcounter.zip"
}

resource "aws_lambda_function" "main" {
  filename         = "lambda-viewcounter.zip" #File is in the same directory where the module call is. If not, use path.module
  function_name    = var.lambda_function_name
  role             = aws_iam_role.main.arn
  handler          = "lambda-viewcounter.lambda_handler" 
  runtime          = "python3.9"

  #This attribute changes whenever you update the code contained in the archive. It lets lambda know that there is a new version of your code available.
  source_code_hash = data.archive_file.main.output_base64sha256

  depends_on = [
    aws_iam_role_policy_attachment.ddbtable_policy_attachment,
    aws_iam_role_policy_attachment.logging_policy_attachment,
    aws_cloudwatch_log_group.main
  ]
}