terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2"
    }
  }

  required_version = ">= 1.3"
}
