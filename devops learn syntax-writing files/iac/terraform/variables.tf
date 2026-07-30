variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region to deploy resources into"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev/staging/prod)"
}

variable "instance_count" {
  type        = number
  default     = 2
  description = "Number of EC2 instances to launch"
}