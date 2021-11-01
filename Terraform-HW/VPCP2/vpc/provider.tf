terraform {
  required_version = "1.0.8"
  required_providers {
    
    aws = {
      version = "3.63.0"
    }
  }
  
  backend "s3" {
    bucket = "alinabucket11"
    key = "terraform/states/vpc2/vpc"
    region = "us-east-1"
    
  }
}
provider "aws" {
  region  = var.aws_region

  default_tags {
    tags = {
      Owner = var.owner_tag
      Purpose = var.purpose_tag
    }
  }
}
