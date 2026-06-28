variable "service_name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}
