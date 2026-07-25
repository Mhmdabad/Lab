# variables.tf — CONCEPT: input variables
#
# Variables make your config reusable: same code, different values per
# environment. Each has a type, an optional default, and can be validated.

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"

  # validation blocks reject bad input at plan time instead of failing later.
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (from the Networking stage: CIDR notation)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro" # free-tier friendly
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH in. Lock this to YOUR IP, never 0.0.0.0/0."
  type        = string
  default     = "203.0.113.0/24" # TEST-NET placeholder — change to your.ip/32
}

variable "ssh_public_key" {
  description = "Your SSH public key contents, for EC2 key pair"
  type        = string
  default     = ""   # supply in terraform.tfvars
  sensitive   = true # hide from CLI output & logs
}

variable "bucket_name_prefix" {
  description = "Prefix for the globally-unique S3 bucket name"
  type        = string
  default     = "devops-roadmap-stage06"
}
