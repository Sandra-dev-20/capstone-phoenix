output "control_plane_public_ip" {
  description = "Control plane public IP"
  value       = aws_instance.control_plane.public_ip
}

output "control_plane_private_ip" {
  description = "Control plane private IP"
  value       = aws_instance.control_plane.private_ip
}

output "worker_public_ips" {
  description = "Worker node public IPs"
  value       = aws_instance.worker[*].public_ip
}

output "worker_private_ips" {
  description = "Worker node private IPs"
  value       = aws_instance.worker[*].private_ip
}

