resource "aws_accessanalyzer_analyzer" "account_internal" {
  for_each = toset(var.regions)

  analyzer_name = "account-internal-access-analyzer-${each.value}"
  type          = "ACCOUNT_INTERNAL_ACCESS"
  region        = each.value

  tags = var.tags
}

resource "aws_accessanalyzer_archive_rule" "filter_resources" {
  for_each = toset(var.regions)

  analyzer_name = aws_accessanalyzer_analyzer.account_internal[each.value].analyzer_name
  rule_name     = "archive-non-monitored-resources"
  region        = each.value

  filter {
    criteria = "resourceType"
    neq      = var.resource_types
  }
}
