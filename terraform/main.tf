# Main Terraform configuration file for EKS deployment

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  cluster_name         = local.cluster_name
  ec2_ssh_key_name     = var.ec2_ssh_key_name
  allowed_ssh_cidr_blocks = var.allowed_ssh_cidr_blocks
  tags                 = local.tags
}

# IAM Module for admin access - created before EKS
module "iam_pre" {
  source = "./modules/iam-pre"

  cluster_name       = local.cluster_name
  caller_identity_arn = data.aws_caller_identity.current.arn
  admin_arns         = var.admin_arns
  tags               = local.tags
}

# IAM Module for OIDC-based roles - created after EKS
module "iam_post" {
  source = "./modules/iam-post"

  cluster_name       = local.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url
  tags               = local.tags

  depends_on = [module.eks]
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name              = local.cluster_name
  kubernetes_version        = var.kubernetes_version
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnets
  worker_node_instance_types = var.worker_node_instance_types
  worker_node_min_size      = var.worker_node_min_size
  worker_node_max_size      = var.worker_node_max_size
  worker_node_desired_size  = var.worker_node_desired_size
  ec2_ssh_key_name          = var.ec2_ssh_key_name
  bastion_sg_id             = module.vpc.bastion_sg_id
  eks_admin_role_arn        = module.iam_pre.eks_admin_role_arn
  tags                      = local.tags

  depends_on = [module.vpc, module.iam_pre]
}

# EKS Addons Module
module "eks_addons" {
  source = "./modules/eks-addons"

  cluster_name                          = module.eks.cluster_name
  depends_on_eks                        = module.eks.cluster_id
  oidc_provider_arn                     = module.eks.oidc_provider_arn
  oidc_provider_url                     = module.eks.oidc_provider_url
  aws_load_balancer_controller_policy_arn = module.iam_post.aws_load_balancer_controller_policy_arn
  tags                                  = local.tags

  depends_on = [module.eks, module.iam_post]
}

# Outputs
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "bastion_ip" {
  description = "Public IP of the bastion host"
  value       = module.vpc.bastion_ip
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the cluster autoscaler IAM role"
  value       = module.iam_post.cluster_autoscaler_role_arn
}

output "external_dns_role_arn" {
  description = "ARN of the external-dns IAM role"
  value       = module.iam_post.external_dns_role_arn
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the Load Balancer Controller IAM role"
  value       = module.eks_addons.load_balancer_controller_role_arn
}

output "eks_addons" {
  description = "Installed EKS addons"
  value       = module.eks_addons.eks_addons
}