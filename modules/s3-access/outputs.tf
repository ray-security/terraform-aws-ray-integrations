output "policy_name" {
  description = "Name of the inline policy"
  value       = aws_iam_role_policy.this.name
}

output "policy_json" {
  description = "The inline policy, as JSON"
  value       = data.aws_iam_policy_document.additional_read_access.json
}

output "remediation_policy_json" {
  description = "The remediation inline policy, as JSON; null when remediation is off"
  value       = var.enable_remediation ? data.aws_iam_policy_document.remediation.json : null
}
