variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for nodes"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for nodes"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for nodes"
  type        = string
}

