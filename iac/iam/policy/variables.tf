variable "policy_name" {
  type = string
  description = "Policy name"
}

variable "policy_description" {
  type = string
  description = "Policy description"
}

variable "policy_actions" {
  type = list(string)
  description = "Policy actions"
}

variable "resource_arn" {
  type = string
  description = "Resource arn"
}

variable "role_arn" {
  type = list(string)
  description = "Role arn"
}