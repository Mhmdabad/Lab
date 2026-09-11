resource "aws_iam_user" "mlflow" {
  name = "${var.project_name}-mlflow"
}

resource "aws_iam_user_policy" "mlflow_s3" {
  name = "${var.project_name}-s3-policy"
  user = aws_iam_user.mlflow.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.mlflow_artifacts.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.mlflow_artifacts.arn}/*"
      }
    ]
  })
}

resource "aws_iam_access_key" "mlflow" {
  user = aws_iam_user.mlflow.name
}