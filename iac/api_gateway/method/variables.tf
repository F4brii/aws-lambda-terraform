variable "aws_api_gateway_resource_id" {
  type        = string
  description = "Api Gateway resource id"
}

variable "api_gateway_id" {
  type        = string
  description = "Api Gateway id"
}

variable "api_gateway_root_resource_id" {
  type        = string
  description = "Api Gateway root resource id"
}

variable "api_gateway_execution_arn" {
  type        = string
  description = "Api Gateway execution arn"
}

variable "http_method" {
  type        = string
  description = "Rest api id"
}

variable "authorization" {
  type        = string
  description = "Authorization"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Lambda invoke arn"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "lambda_name" {
  type        = string
  description = "Lambda name"
}
