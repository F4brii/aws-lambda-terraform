resource "aws_iam_policy" "iam_policy" {
  name        = var.policy_name
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = var.policy_actions,
      Resource = var.resource_arn
    }]
  })
}

resource "aws_iam_policy_attachment" "policy_attachment" {
  policy_arn = aws_iam_policy.iam_policy.arn
  roles      = var.role_arn
  name       = "policy_attachment"
}
