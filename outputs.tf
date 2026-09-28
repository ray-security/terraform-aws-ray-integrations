output "role_arn" {
  description = "ARN of the S3 scanning role. Its 12-digit account ID goes on the Ray Security S3 setup screen"
  value       = one(module.role[*].arn)
}

output "identity_center_role_arn" {
  description = "ARN of the Identity Center role"
  value       = one(module.identity_center_role[*].arn)
}

output "access_analyzer_arns" {
  description = "Access Analyzer ARNs by region"
  value       = one(module.access_analyzer[*].arns)
}
