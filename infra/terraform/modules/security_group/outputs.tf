output "nodes_sg_id" {
  description = "Security group ID for cluster nodes"
  value       = aws_security_group.nodes.id
}


