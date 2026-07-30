output "server_public_ips" {
  description = "Public IPs of all created servers"
  value       = aws_instance.web_server[*].public_ip
}

output "security_group_id" {
  description = "ID of the created Security Group"
  value       = aws_security_group.web_sg.id
}