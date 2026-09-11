output "rds_endpoint" {
  value = aws_db_instance.mlflow.address
}

output "rds_port" {
  value = aws_db_instance.mlflow.port
}

output "db_name" {
  value = aws_db_instance.mlflow.db_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.mlflow_artifacts.bucket
}

output "s3_bucket_uri" {
  value = "s3://${aws_s3_bucket.mlflow_artifacts.bucket}"
}

output "mlflow_aws_access_key_id" {
  value     = aws_iam_access_key.mlflow.id
  sensitive = true
}

output "mlflow_aws_secret_access_key" {
  value     = aws_iam_access_key.mlflow.secret
  sensitive = true
}