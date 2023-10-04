variable "api_gateway_name" {
  type        = string
  description = "Api Gateway name"
}

variable "path_part" {
  type        = string
  description = "Rest api id"
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
