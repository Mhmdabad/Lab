variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "mlops-practice"
}

variable "db_name" {
  type    = string
  default = "mlflow"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "allowed_cidr" {
  description = "CIDR allowed to connect to PostgreSQL"
  type        = string
}