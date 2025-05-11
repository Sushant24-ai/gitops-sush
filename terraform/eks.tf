# EKS cluster specific configurations

# Enhanced logging for the EKS cluster
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = 7
  tags              = local.tags
}

# Additional EKS configurations (if needed beyond what's in main.tf)

# Create the AWS EKS add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"
  addon_version = "v1.13.2-eksbuild.1"  # Update to the latest compatible version

  depends_on = [
    module.eks
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
  addon_version = "v1.10.1-eksbuild.1"  # Update to the latest compatible version

  depends_on = [
    module.eks
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"
  addon_version = "v1.27.1-eksbuild.1"  # Update to the latest compatible version

  depends_on = [
    module.eks
  ]
}

# Optional: AWS Load Balancer Controller
# Note: This requires Helm and kubectl configuration, so it's usually set up later via the script

# OIDC Identity Provider
data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url
}

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "load_balancer_controller" {
  name = "${local.cluster_name}-lb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${local.cluster_name}-ebs-csi-driver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Optional: EBS CSI Driver addon
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = module.eks.cluster_name
  addon_name   = "aws-ebs-csi-driver"
  addon_version = "v1.19.0-eksbuild.2"  # Update to the latest compatible version
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  depends_on = [
    module.eks
  ]
}

# Outputs for EKS addons
output "eks_addons" {
  description = "Installed EKS addons"
  value = {
    vpc_cni   = aws_eks_addon.vpc_cni.id
    coredns   = aws_eks_addon.coredns.id
    kube_proxy = aws_eks_addon.kube_proxy.id
    ebs_csi_driver = aws_eks_addon.ebs_csi_driver.id
  }
}
