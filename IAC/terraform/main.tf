resource "local_file" "name" {
  filename = var.file_name
  content  = "Hello World"
}