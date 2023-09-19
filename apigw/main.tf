#Create a HTTP API with CORS
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

#A Lambda proxy integration enables you to integrate an API route with a Lambda function. When a client calls your API, API Gateway sends the request to the Lambda function and returns the function's response to the client
resource "aws_apigatewayv2_integration" "main" {
  api_id                  = aws_apigatewayv2_api.main.id
  integration_uri         = var.lambda_invoke_arn
  payload_format_version  = "2.0"
  integration_type        = "AWS_PROXY"
  integration_method      = "POST"
}

#Routes direct incoming API requests to backend resources.
resource "aws_apigatewayv2_route" "main" {
  api_id = aws_apigatewayv2_api.main.id

  #ANY Method to resource_path
  route_key = "ANY /${var.lambda_function_name}"

  #Target of the route
  target    = "integrations/${aws_apigatewayv2_integration.main.id}" 
}

#Gives an external resource (APIGW) permission to access the lambda function.
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/${var.lambda_function_name}"
}