resource "aws_accessanalyzer_analyzer" "account_internal" {
  for_each = toset(var.regions)

  analyzer_name = "ray-security-internal-access-${each.value}"
  type          = "ACCOUNT_INTERNAL_ACCESS"
  region        = each.value

  configuration {
    internal_access {
      analysis_rule {
        inclusion {
          resource_types = var.resource_types
        }
      }
    }
  }

  tags = var.tags
}
