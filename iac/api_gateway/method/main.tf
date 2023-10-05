resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id   = var.api_gateway_id
  resource_id   = var.aws_api_gateway_resource_id
  http_method   = var.http_method
  authorization = var.authorization
}

resource "aws_api_gateway_integration" "api_gateway_integration" {
  rest_api_id             = var.api_gateway_id
  resource_id             = aws_api_gateway_method.api_gateway_method.resource_id
  http_method             = aws_api_gateway_method.api_gateway_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = var.api_gateway_id
  stage_name  = var.env

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
