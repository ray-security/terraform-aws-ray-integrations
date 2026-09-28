variable "role_name" {
  description = "Name of the IAM role the policy is attached to"
  type        = string
}

variable "inline_policy_name" {
  description = "Name of the inline policy"
  type        = string
  default     = "RaySecurityReadAccess"
}

variable "s3_bucket_names" {
  description = "S3 buckets Ray Security may read. Empty means all buckets"
  type        = list(string)
  default     = []
}

variable "include_kms_permissions" {
  description = "Allow describing and decrypting SSE-KMS encrypted objects"
  type        = bool
  default     = false
}
