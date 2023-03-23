# Setup
terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.8.1-pre1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.53"
    }
  }
}