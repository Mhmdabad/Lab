# main.tf — CONCEPT: resources & provisioners
#
# This file provisions a minimal but realistic stack:
#   VPC → subnet → internet gateway → route table → security group → EC2 → S3
# It is written to PASS Checkov/tfsec, and includes one commented insecure
# block so you can practise the scan-fix loop.

# ---------------------------------------------------------------------------
# Data sources: read existing info from the provider (not create anything).
# ---------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# Latest Amazon Linux 2023 AMI, looked up dynamically instead of hard-coded.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.environment}-vpc" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.environment}-public-subnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "${var.environment}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Security group — note SSH is limited to var.allowed_ssh_cidr, NOT 0.0.0.0/0.
# This is the #1 misconfig Checkov/tfsec look for.
# ---------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Allow HTTP from anywhere and SSH from a trusted range"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # a public web server: HTTP open is expected
  }

  ingress {
    description = "SSH from trusted range only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # ---- INSECURE-ON-PURPOSE (learning exercise) --------------------------
  # Uncomment this and re-run `security/run-scans.sh`. Checkov & tfsec will
  # flag "SSH open to the world". Then re-comment it to fix.
  # ingress {
  #   description = "SSH open to the world - DO NOT DO THIS"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # -----------------------------------------------------------------------

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-web-sg" }
}

# ---------------------------------------------------------------------------
# Compute — EC2 instance with provisioners
# ---------------------------------------------------------------------------
resource "aws_key_pair" "deployer" {
  count      = var.ssh_public_key == "" ? 0 : 1
  key_name   = "${var.environment}-deployer-key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.ssh_public_key == "" ? null : aws_key_pair.deployer[0].key_name

  # Security best-practice: force IMDSv2 (Checkov checks for this).
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted   = true # encrypt the disk (another Checkov check)
    volume_size = 8
    volume_type = "gp3"
  }

  # CONCEPT: provisioners --------------------------------------------------
  # local-exec runs a command on YOUR machine after the resource is created.
  # Here we write the instance IP to a file Ansible can read as inventory.
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ${path.module}/.web_ip.txt"
  }

  # NOTE on remote-exec: a `remote-exec` provisioner runs commands ON the new
  # instance over SSH and needs a `connection` block. It's a "last resort" —
  # prefer Ansible (Part B) or user_data below. Example, for reference:
  #
  #   provisioner "remote-exec" {
  #     inline = ["sudo dnf install -y htop"]
  #     connection {
  #       type        = "ssh"
  #       host        = self.public_ip
  #       user        = "ec2-user"
  #       private_key = file("~/.ssh/id_rsa")
  #     }
  #   }

  # user_data is the preferred alternative to remote-exec: cloud-init bootstrap.
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable --now nginx
    echo "<h1>Provisioned by Terraform — ${var.environment}</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = { Name = "${var.environment}-web" }
}

# ---------------------------------------------------------------------------
# Storage — S3 bucket, configured securely (private, encrypted, versioned).
# ---------------------------------------------------------------------------
# Derive a globally-unique bucket name from the account id (no extra provider
# needed). S3 bucket names must be unique across ALL of AWS.
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.bucket_name_prefix}-${data.aws_caller_identity.current.account_id}"
  tags   = { Name = "${var.environment}-assets" }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}
