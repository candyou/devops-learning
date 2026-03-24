terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state sur S3
  backend "s3" {
    bucket         = "devops-learning-tfstate-2026"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "devops-learning-terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}