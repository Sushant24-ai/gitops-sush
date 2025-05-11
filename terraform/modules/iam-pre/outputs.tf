output "eks_admin_role_arn" {
  description = "ARN of the EKS admin IAM role"
  value       = aws_iam_role.eks_admin_role.arn
}