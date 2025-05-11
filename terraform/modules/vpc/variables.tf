variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "ec2_ssh_key_name" {
  description = "Name of the EC2 SSH key pair to use for worker node access"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}