output "arns" {
  description = "Analyzer ARNs by region"
  value       = { for region, analyzer in aws_accessanalyzer_analyzer.account_internal : region => analyzer.arn }
}

output "types" {
  description = "Analyzer types by region"
  value       = { for region, analyzer in aws_accessanalyzer_analyzer.account_internal : region => analyzer.type }
}
