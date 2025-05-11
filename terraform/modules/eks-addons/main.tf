# EKS Add-ons

# Enhanced logging for the EKS cluster
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
  tags              = var.tags
}

# Create the AWS EKS add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = var.cluster_name
  addon_name    = "vpc-cni"
  addon_version = "v1.13.2-eksbuild.1"  # Update to the latest compatible version

  depends_on = [
    var.depends_on_eks
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = var.cluster_name
  addon_name    = "coredns"
  addon_version = "v1.10.1-eksbuild.1"  # Update to the latest compatible version

  depends_on = [
    var.depends_on_eks
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = var.cluster_name
  addon_name    = "kube-proxy"
  addon_version = "v1.27.1-eksbuild.1"  # Update to the latest compatible version

  depends_on = [
    var.depends_on_eks
  ]
}

# IAM Role for Load Balancer Controller
resource "aws_iam_role" "load_balancer_controller" {
  name = "${var.cluster_name}-lb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = var.aws_load_balancer_controller_policy_arn
}

# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.cluster_name}-ebs-csi-driver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Optional: EBS CSI Driver addon
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.19.0-eksbuild.2"  # Update to the latest compatible version
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  depends_on = [
    var.depends_on_eks
  ]
}