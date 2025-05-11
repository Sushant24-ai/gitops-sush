variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "caller_identity_arn" {
  description = "ARN of the AWS caller identity"
  type        = string
}

variable "admin_arns" {
  description = "List of IAM ARNs for users/roles who should have admin access to the cluster"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}