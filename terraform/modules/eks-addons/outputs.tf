output "eks_addons" {
  description = "Installed EKS addons"
  value = {
    vpc_cni        = aws_eks_addon.vpc_cni.id
    coredns        = aws_eks_addon.coredns.id
    kube_proxy     = aws_eks_addon.kube_proxy.id
    ebs_csi_driver = aws_eks_addon.ebs_csi_driver.id
  }
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the Load Balancer Controller IAM role"
  value       = aws_iam_role.load_balancer_controller.arn
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI Driver IAM role"
  value       = aws_iam_role.ebs_csi_driver.arn
}