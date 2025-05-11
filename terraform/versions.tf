# Terraform version and required providers

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
  }

  # Optional: Configure a remote backend
  # backend "s3" {
  #   bucket = "example-terraform-state-bucket"
  #   key    = "gitops-eks/terraform.tfstate"
  #   region = "us-west-2"
  #   encrypt = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}
