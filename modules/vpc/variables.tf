# modules/vpc/variables.tf
# These are the inputs our VPC module accepts.
# The root module will pass these values in.

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
}

variable "project_name" {
  description = "Name prefix for all resources"
  type = string
}

variable "environment" {
  description = "Environment name (production, staging, etc.)"
  type = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type = list(string)
}

variable "availability_zones" {
  description = "List of AZs to spread subnets across"
  type = list(string)
}