resource "aws_db_instance" "mlflow" {
  identifier = "${var.project_name}-db"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  publicly_accessible = true
  multi_az            = false

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name    = "${var.project_name}-db"
    Project = var.project_name
  }
}