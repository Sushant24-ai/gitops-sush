# EKS Cluster and Node Group Configuration

# Create EKS Cluster and associated resources
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = var.private_subnet_ids

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # OIDC provider is needed for AWS Load Balancer Controller and other AWS services
  enable_irsa = true

  # Define node groups
  eks_managed_node_groups = {
    main = {
      name = "main-node-group"

      instance_types = var.worker_node_instance_types
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"

      min_size     = var.worker_node_min_size
      max_size     = var.worker_node_max_size
      desired_size = var.worker_node_desired_size

      disk_size = 50

      # Use launch template to customize
      create_launch_template = true
      launch_template_name   = "${var.cluster_name}-launch-template"

      # Remote access to worker nodes
      remote_access = {
        ec2_ssh_key               = var.ec2_ssh_key_name
        source_security_group_ids = [var.bastion_sg_id]
      }

      tags = merge(
        var.tags,
        {
          "k8s.io/cluster-autoscaler/enabled" = "true"
          "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
        }
      )
    }
  }

  # AWS Auth ConfigMap
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = var.eks_admin_role_arn
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  # Add additional security groups to worker nodes
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.tags
}

# Create OIDC Identity Provider
data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url
}