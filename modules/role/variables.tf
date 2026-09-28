variable "name" {
  description = "Name of the IAM role"
  type        = string
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
}

variable "trusted_account_arn" {
  description = "AWS principal allowed to assume the role (the Ray Security AWS account)"
  type        = string
}

variable "external_id" {
  description = "External ID the Ray Security AWS account must present to assume the role"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the role"
  type        = map(string)
  default     = {}
}
