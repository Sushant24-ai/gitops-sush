variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "depends_on_eks" {
  description = "Resource dependency for EKS cluster"
  type        = any
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider without the https:// prefix"
  type        = string
}

variable "aws_load_balancer_controller_policy_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM policy"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}