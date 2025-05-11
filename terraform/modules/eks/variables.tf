variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "worker_node_instance_types" {
  description = "Instance types to use for worker nodes"
  type        = list(string)
}

variable "worker_node_min_size" {
  description = "Minimum size of worker node group"
  type        = number
}

variable "worker_node_max_size" {
  description = "Maximum size of worker node group"
  type        = number
}

variable "worker_node_desired_size" {
  description = "Desired size of worker node group"
  type        = number
}

variable "ec2_ssh_key_name" {
  description = "Name of the EC2 SSH key pair to use for worker node access"
  type        = string
  default     = ""
}

variable "bastion_sg_id" {
  description = "ID of the bastion security group"
  type        = string
}

variable "eks_admin_role_arn" {
  description = "ARN of the EKS admin IAM role"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}