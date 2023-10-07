variable "function_name" {
  type        = string
  description = "Function name"
}

variable "filename" {
  type        = string
  description = "File name"
}

variable "role_arn" {
  type        = string
  description = "Role arn"
}

variable "handler" {
  type        = string
  description = "Handler"
}

variable "runtime" {
  type        = string
  description = "Runtime"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ids"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group ids"
}

variable "lambda_env" {
  type = map(any)
  description = "env"
}
