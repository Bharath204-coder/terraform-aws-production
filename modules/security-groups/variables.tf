variable "project_name" {
  description = "Project name prefix"
  type = string
}

variable "environment" {
  description = "Environment name"
  type = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type = string
}