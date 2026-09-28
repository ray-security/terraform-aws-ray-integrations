output "policy_name" {
  description = "Name of the inline policy"
  value       = aws_iam_role_policy.this.name
}

output "policy_json" {
  description = "The inline policy, as JSON"
  value       = data.aws_iam_policy_document.identity_center_read_access.json
}
