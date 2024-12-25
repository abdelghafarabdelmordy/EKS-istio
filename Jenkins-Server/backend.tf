terraform {
  backend "s3" {
    bucket         = "eks-tf-dev-cluster3001"
    region         = "eu-west-1"
    key            = "Jenkins-Server-TF/terraform.tfstate"
    dynamodb_table = "Lock-Files"
    encrypt        = true
  }


  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}