variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "project" {
  type    = string
  default = "careguide-task"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "http_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "github_repository" {
  type    = string
  default = "shohan2032/careguide-task"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "create_github_oidc_provider" {
  type    = bool
  default = true
}

variable "create_evaluator_user" {
  type    = bool
  default = true
}
