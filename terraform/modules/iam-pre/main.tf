# Pre-EKS IAM roles and policies

# Admin role for EKS cluster management
resource "aws_iam_role" "eks_admin_role" {
  name = "${var.cluster_name}-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = concat([var.caller_identity_arn], var.admin_arns)
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach the necessary policies to the admin role
resource "aws_iam_role_policy_attachment" "eks_admin_role_attachment" {
  role       = aws_iam_role.eks_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}