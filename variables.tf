variable "env" {
  description = "Environments"
  type        = string
}
variable "region" {
  description = "AWS region"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet cidr"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "Vpc cidr"
  type        = string
}
