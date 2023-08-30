
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
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

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"
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
    }]
  })
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

data "archive_file" "zip_nodejs_code" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "${path.module}/node-code.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "func-hello"
  filename      = "${path.module}/node-code.zip"
  role          = aws_iam_role.lambda_role.arn
  handler       = "src/index.handler"
  runtime       = "nodejs14.x"
}
