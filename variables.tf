# variables.tf
# Root-level variables. Values come from terraform.tfvars below.

variable "aws_region" {
  description = "AWS region to deploy into"
  type = string
  default = "us-east-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resources"
  type = string
}

variable "environment" {
  description = "Environment name"
  type = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}