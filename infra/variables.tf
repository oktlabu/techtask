variable "project_name" {
  description = "The name of project."
  type = string
  default = "risktec"
}

variable "location" {
  description = "Location of resources."
  type = string
  default = "westeurope"
}

variable "env" {
  description = "Environment."
  type = string
  default = "dev"
}

variable "repo_name" {
  description = "Type Repository Name"
  default     = "risktec-fask-api"
}

variable "tag_name" {
  description = "Type Image Tag"
  default     = "v1"
}

variable "container_port" {
  description = "Port for the container application."
  type        = number
  default     = 5000
}

variable "rule_type" {
  description = "Type of request routing rule"
  default     = "Basic"
}
