resource "aws_apigatewayv2_api" "main" {
  name                       = var.apigw_name
  protocol_type              = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
  }
}

resource "aws_apigatewayv2_stage" "main"{
  api_id = aws_apigatewayv2_api.main.id

  name = "dev"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "main" {
  api_id                  = aws_apigatewayv2_api.main.id
  integration_uri         = var.lambda_invoke_arn
  payload_format_version  = "2.0"
  integration_type        = "AWS_PROXY"
  integration_method      = "POST"
}

resource "aws_apigatewayv2_route" "main" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "ANY /Test_lambda"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}" 
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/Test_lambda"
}