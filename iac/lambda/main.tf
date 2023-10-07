resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  filename      = var.filename
  role          = var.role_arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = 15

  environment {
    variables = var.lambda_env
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}
