# IAM roles and policies for EKS

# Admin role for EKS cluster management
resource "aws_iam_role" "eks_admin_role" {
  name = "${local.cluster_name}-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = concat([data.aws_caller_identity.current.arn], var.admin_arns)
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

# Attach the necessary policies to the admin role
resource "aws_iam_role_policy_attachment" "eks_admin_role_attachment" {
  role       = aws_iam_role.eks_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Cluster autoscaler IAM policy
resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${local.cluster_name}-cluster-autoscaler"
  description = "Policy for cluster autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.tags
}

# Cluster autoscaler IAM role
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${local.cluster_name}-cluster-autoscaler"

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
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })

  tags = local.tags
}

# Attach the cluster autoscaler policy to the role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

# IAM policy for external-dns
resource "aws_iam_policy" "external_dns" {
  name        = "${local.cluster_name}-external-dns"
  description = "Policy for external-dns"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })

  tags = local.tags
}

# IAM role for external-dns
resource "aws_iam_role" "external_dns" {
  name = "${local.cluster_name}-external-dns"

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
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })

  tags = local.tags
}

# Attach the external-dns policy to the role
resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

# Output IAM roles for reference
output "cluster_autoscaler_role_arn" {
  description = "ARN of the cluster autoscaler IAM role"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "external_dns_role_arn" {
  description = "ARN of the external-dns IAM role"
  value       = aws_iam_role.external_dns.arn
}
