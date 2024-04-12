terraform {
  required_version = "~> 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44"
    }
  }

  # TODO: add your choice of remote state solution
}

provider "aws" {
}
