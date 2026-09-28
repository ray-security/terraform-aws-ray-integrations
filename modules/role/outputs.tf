output "arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

output "name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
}

output "assume_role_policy" {
  description = "Trust policy of the role, as JSON"
  value       = data.aws_iam_policy_document.trust.json
}
