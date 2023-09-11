
resource "aws_vpc" "vcp_main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "subnet_public" {
  cidr_block              = var.subnet_cidr
  vpc_id                  = aws_vpc.vcp_main.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public"
  }

  depends_on = [aws_vpc.vcp_main]
}

resource "aws_security_group" "security_group_main" {
  name        = "security-group-main"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vcp_main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gps_main"
  }

  depends_on = [aws_vpc.vcp_main]
}

resource "aws_iam_role" "iam_role_person" {
  name = "iam-role-person"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "logs_policy" {
  name = "logs-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = ["arn:aws:logs:*:*:*"]
      }, {
      Effect = "Allow"
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ]
      Resource = ["*"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "logs_policy_attachment" {
  policy_arn = aws_iam_policy.logs_policy.arn
  role       = aws_iam_role.iam_role_person.name
  depends_on = [aws_iam_policy.logs_policy, aws_iam_role.iam_role_person]
}

data "archive_file" "zip_nodejs_code" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "${path.module}/node-code.zip"
}

resource "aws_lambda_function" "func_get_person_list" {
  function_name = "func-get-person-list"
  filename      = "${path.module}/node-code.zip"
  role          = aws_iam_role.iam_role_person.arn
  handler       = "src/index.handler"
  runtime       = "nodejs14.x"

  vpc_config {
    subnet_ids         = [aws_subnet.subnet_public.id]
    security_group_ids = [aws_security_group.security_group_main.id]
  }

  depends_on = [aws_security_group.security_group_main]
}

resource "aws_api_gateway_rest_api" "api_gateway_main" {
  name        = "api-gatway-main"
  description = "API Gateway main"
}

resource "aws_api_gateway_resource" "api_gateway_resource" {
  parent_id   = aws_api_gateway_rest_api.api_gateway_main.root_resource_id
  path_part   = "person"
  rest_api_id = aws_api_gateway_rest_api.api_gateway_main.id
  depends_on  = [aws_api_gateway_rest_api.api_gateway_main]
}

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_main.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = "GET"
  authorization = "NONE"
  depends_on    = [aws_api_gateway_rest_api.api_gateway_main, aws_api_gateway_resource.api_gateway_resource]
}

resource "aws_api_gateway_integration" "api_gateway_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_main.id
  resource_id             = aws_api_gateway_resource.api_gateway_resource.id
  http_method             = aws_api_gateway_method.api_gateway_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.func_get_person_list.invoke_arn
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  depends_on = [aws_api_gateway_integration.api_gateway_integration]

  rest_api_id = aws_api_gateway_rest_api.api_gateway_main.id
  stage_name  = var.env
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func_get_person_list.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_rest_api.api_gateway_main.execution_arn
}
