output "control_plane_public_ip" {
  description = "Control plane public IP"
  value       = module.compute.control_plane_public_ip
}

output "control_plane_private_ip" {
  description = "Control plane private IP"
  value       = module.compute.control_plane_private_ip
}

output "worker_public_ips" {
  description = "Worker node public IPs"
  value       = module.compute.worker_public_ips
}

output "worker_private_ips" {
  description = "Worker node private IPs"
  value       = module.compute.worker_private_ips
}

