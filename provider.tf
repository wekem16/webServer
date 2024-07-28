terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}


terraform {
  cloud {
    organization = "wekem16"

    workspaces {
      name = "webServer"
    }
  }
}

provider "aws" {
   region = var.region
   secret_key = var.SecretAccessKey
   access_key = var.AccessKey
}