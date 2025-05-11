output "eks_admin_role_arn" {
  description = "ARN of the EKS admin IAM role"
  value       = aws_iam_role.eks_admin_role.arn
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the cluster autoscaler IAM role"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "external_dns_role_arn" {
  description = "ARN of the external-dns IAM role"
  value       = aws_iam_role.external_dns.arn
}

output "aws_load_balancer_controller_policy_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM policy"
  value       = aws_iam_policy.aws_load_balancer_controller.arn
}