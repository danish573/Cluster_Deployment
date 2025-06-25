terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "latest"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}