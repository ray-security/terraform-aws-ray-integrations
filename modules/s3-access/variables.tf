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

variable "enable_remediation" {
  description = "Attach the remediation policy: change bucket policies, Block Public Access and object tags on remediation_bucket_names"
  type        = bool
  default     = false
}

variable "remediation_bucket_names" {
  description = "Buckets the remediation policy may change; required with enable_remediation"
  type        = list(string)
  default     = []

  validation {
    condition     = !var.enable_remediation || length(var.remediation_bucket_names) > 0
    error_message = "enable_remediation needs remediation_bucket_names: list the buckets remediation actions may change."
  }

  validation {
    condition     = alltrue([for bucket in var.remediation_bucket_names : can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", bucket))])
    error_message = "remediation_bucket_names takes plain S3 bucket names: 3-63 characters, lowercase letters, digits, dots and hyphens, no wildcards or paths."
  }
}

variable "remediation_policy_name" {
  description = "Name of the remediation inline policy"
  type        = string
  default     = "RaySecurityRemediationAccess"
}
