# versions.tf
# Declares which Terraform version and providers this project needs.
# This is what gets locked in .terraform.lock.hcl after terraform init.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-prod-bharathcm-200044"
    key = "project1/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = var.project_name
      Environment = var.environment
      ManagedBy = "Terraform"
    }
  }
}