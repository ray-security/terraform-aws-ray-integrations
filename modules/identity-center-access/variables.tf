variable "role_name" {
  description = "Name of the IAM role the policy is attached to"
  type        = string
}

variable "inline_policy_name" {
  description = "Name of the inline policy"
  type        = string
  default     = "RaySecurityIdentityCenterReadAccess"
}
