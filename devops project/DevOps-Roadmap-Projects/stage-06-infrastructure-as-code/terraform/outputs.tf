# outputs.tf — CONCEPT: outputs
#
# Outputs export values after apply: for humans (terraform output) and for
# other tools (Ansible reads the EC2 IP to build its inventory).

output "web_public_ip" {
  description = "Public IP of the web EC2 instance"
  value       = aws_instance.web.public_ip
}

output "web_public_dns" {
  description = "Public DNS name of the web instance"
  value       = aws_instance.web.public_dns
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "assets_bucket" {
  description = "Name of the S3 assets bucket"
  value       = aws_s3_bucket.assets.bucket
}

output "ssh_command" {
  description = "Ready-to-paste SSH command (if you supplied a key)"
  # References var.ssh_public_key (marked sensitive), so this output inherits
  # that taint and must be marked sensitive too. It only reveals whether a key
  # was set, but Terraform is strict about propagation — mark it explicitly.
  value     = var.ssh_public_key == "" ? "no key provided" : "ssh ec2-user@${aws_instance.web.public_ip}"
  sensitive = true
}
