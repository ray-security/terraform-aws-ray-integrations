variable "external_id" {
  description = "External ID shown on the Ray Security S3 setup screen. Ray Security can assume the roles only when it presents it"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.external_id) >= 2 && length(var.external_id) <= 1224 && can(regex("^[\\w+=,.@:/-]+$", var.external_id))
    error_message = "external_id must be the External ID shown on the Ray Security S3 setup screen (2-1224 characters of letters, digits and _+=,.@:/-)."
  }
}

variable "account_id" {
  description = "12-digit ID of the AWS account this configuration is for. When set, plan fails before any change unless the AWS credentials belong to that account"
  type        = string
  default     = null

  validation {
    condition     = var.account_id == null || can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "trusted_account_arn" {
  description = "AWS principal allowed to assume the roles. Change it only if the setup screen shows a different trusted principal"
  type        = string
  default     = "arn:aws:iam::992382604000:root"
}

variable "enable_s3" {
  description = "Create the role Ray Security uses to scan this account's S3 buckets and IAM"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name of the S3 scanning role"
  type        = string
  default     = "RaySecurityRole"
}

variable "s3_bucket_names" {
  description = "Buckets Ray Security may read. Empty means all buckets. Include the bucket your CloudTrail and S3 access logs are written to"
  type        = list(string)
  default     = []
}

variable "include_kms_permissions" {
  description = "Allow decrypting SSE-KMS encrypted objects and log files"
  type        = bool
  default     = false
}

variable "enable_identity_center" {
  description = "Create the Identity Center role. Set true only in your AWS Organizations management account"
  type        = bool
  default     = false
}

variable "identity_center_role_name" {
  description = "Name of the Identity Center role"
  type        = string
  default     = "RaySecurityIdentityCenterRole"
}

variable "access_analyzer_regions" {
  description = "Regions to create an account-internal Access Analyzer in (AWS charges for it). Use the regions of your buckets. Empty creates none"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to every resource"
  type        = map(string)
  default     = {}
}
