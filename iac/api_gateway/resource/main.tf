resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = var.path_part
}