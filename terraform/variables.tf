# Variables for the Terraform EKS deployment

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "gitops-demo"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.27"
}

variable "worker_node_instance_types" {
  description = "Instance types to use for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "worker_node_min_size" {
  description = "Minimum size of worker node group"
  type        = number
  default     = 2
}

variable "worker_node_max_size" {
  description = "Maximum size of worker node group"
  type        = number
  default     = 5
}

variable "worker_node_desired_size" {
  description = "Desired size of worker node group"
  type        = number
  default     = 2
}

variable "ec2_ssh_key_name" {
  description = "Name of the EC2 SSH key pair to use for worker node access"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Not recommended for production, narrow this down
}

variable "admin_arns" {
  description = "List of IAM ARNs for users/roles who should have admin access to the cluster"
  type        = list(string)
  default     = []
}
