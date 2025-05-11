variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider without the https:// prefix"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}