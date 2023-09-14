## IAM-Resources ##
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

data "aws_iam_policy_document" "lambda_logging_document" {
  statement {
    effect = "Allow"
    sid = "AllowCWLogGroup"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.main.arn}"]
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

resource "aws_iam_role" "main" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


## CloudWatch ##
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  #retention_in_days = 7
}

## Lambda ##
data "archive_file" "main" {
  type        = "zip"
  source_file = "lambda-viewcounter.py"
  output_path = "lambda-viewcounter.zip"
}

resource "aws_lambda_function" "main" {
  filename         = "lambda-viewcounter.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.main.arn
  handler          = "lambda-viewcounter.lambda_handler" 
  runtime          = "python3.9"
  source_code_hash = data.archive_file.main.output_base64sha256

  depends_on = [
    aws_iam_role_policy_attachment.ddbtable_policy_attachment,
    aws_iam_role_policy_attachment.logging_policy_attachment,
    aws_cloudwatch_log_group.main
  ]
}