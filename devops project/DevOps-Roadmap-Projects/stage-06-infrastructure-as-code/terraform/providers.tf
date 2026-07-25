# providers.tf — CONCEPT: providers & backend
#
# A "provider" is the plugin that lets Terraform talk to an API (AWS, Azure,
# Docker, etc.). `required_providers` pins the source and version so everyone
# on the team gets identical behaviour.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # allow 5.x, block 6.0
    }
  }

  # ---------------------------------------------------------------------------
  # Remote state backend (commented out so this works with zero setup).
  # In a real team you NEVER keep state on your laptop — you store it in S3 with
  # a DynamoDB lock table so two people can't apply at the same time.
  #
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "stage-06/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
  # ---------------------------------------------------------------------------
}

# Provider configuration. Region comes from a variable so it isn't hard-coded.
provider "aws" {
  region = var.aws_region

  # Credentials are NOT set here on purpose. Terraform reads them from the
  # environment (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY) or `aws configure`.
  # Hard-coding keys in .tf files is exactly what Gitleaks is here to catch.

  default_tags {
    tags = {
      Project     = "devops-roadmap-stage-06"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}
