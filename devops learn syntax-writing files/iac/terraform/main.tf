# Security Group
resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Web Servers (Creates N instances based on variable)
resource "aws_instance" "web_server" {
  count         = var.instance_count
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "${var.environment}-web-server-${count.index + 1}"
    Environment = var.environment
  }
}