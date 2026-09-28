locals {
  # Resolve each S3 bucket name to its ARN
  bucket_arns = length(var.s3_bucket_names) > 0 ? [
    for bucket in var.s3_bucket_names : "arn:aws:s3:::${bucket}"
  ] : ["*"]

  # Create object ARNs that cover every object inside the scoped buckets
  bucket_object_arns = length(var.s3_bucket_names) > 0 ? [
    for bucket in var.s3_bucket_names : "arn:aws:s3:::${bucket}/*"
  ] : ["*"]
}

# Inline policy that defines Ray Security's read-only access scope
resource "aws_iam_role_policy" "this" {
  name   = var.inline_policy_name
  role   = var.role_name
  policy = data.aws_iam_policy_document.additional_read_access.json
}

data "aws_iam_policy_document" "additional_read_access" {
  # Allow read-only operations at the bucket level
  statement {
    sid    = "S3BucketReadAccess"
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Describe*",
    ]

    resources = local.bucket_arns
  }

  # Allow read-only operations on every object inside the scoped buckets
  statement {
    sid    = "S3ObjectReadAccess"
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = local.bucket_object_arns
  }

  # Optional SSE-KMS permissions (controlled via include_kms_permissions)
  dynamic "statement" {
    for_each = var.include_kms_permissions ? [1] : []

    content {
      sid    = "S3KMSDecryptAccess"
      effect = "Allow"

      actions = [
        "kms:DescribeKey",
        "kms:ListKeys",
        "kms:ListAliases",
        "kms:ListResourceTags",
        "kms:GetKeyPolicy",
        "kms:GetKeyRotationStatus",
        "kms:Decrypt"
      ]

      resources = ["*"]
    }
  }

  # Account-level discovery APIs that do not support resource-level scoping
  statement {
    sid    = "S3AccountAccess"
    effect = "Allow"

    actions = [
      "s3:GetAccountPublicAccessBlock",
      "s3:ListAllMyBuckets",
      "s3:ListAccessPoints",
      "s3:ListJobs",
    ]

    resources = ["*"]
  }
  # Access Analyzer read permissions
  statement {
    sid    = "ReadAccessAnalyzer"
    effect = "Allow"

    actions = [
      "access-analyzer:ListAnalyzers",
      "access-analyzer:GetAnalyzer",
      "access-analyzer:ListFindings",
      "access-analyzer:GetFinding",
      "access-analyzer:ListFindingsV2",
      "access-analyzer:GetFindingV2"
    ]

    resources = ["*"]
  }

  # CloudTrail read permissions used for activity investigations
  statement {
    sid    = "CloudTrailReadAccess"
    effect = "Allow"

    actions = [
      "cloudtrail:LookupEvents",
      "cloudtrail:GetTrail",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetEventSelectors",
      "cloudtrail:ListTrails",
      "cloudtrail:ListPublicKeys",
      "cloudtrail:ListTags",
      "cloudtrail:GetInsightSelectors",
      "cloudtrail:Get*",
      "cloudtrail:Describe*",
      "cloudtrail:List*"
    ]

    resources = ["*"]
  }

  # AWS Config permissions used to review resource configuration history
  statement {
    sid    = "AWSConfigReadAccess"
    effect = "Allow"

    actions = [
      "config:GetComplianceDetailsByResource",
      "config:GetComplianceSummaryByConfigRule",
      "config:GetResourceConfigHistory",
      "config:BatchGetResourceConfig",
      "config:DescribeConfigRules",
      "config:DescribeComplianceByConfigRule",
      "config:DescribeComplianceByResource",
      "config:DescribeConfigurationRecorders",
      "config:DescribeDeliveryChannels",
      "config:Get*",
      "config:Describe*",
      "config:List*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "IAMReadAccess"
    effect = "Allow"
    actions = [

      "iam:ListRoles",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListUsers",
      "iam:GetUser",
      "iam:ListUserPolicies",
      "iam:ListAttachedUserPolicies",
      "iam:GetGroup",
      "iam:ListGroups",
      "iam:GetGroupPolicy",
      "iam:ListGroupPolicies",
      "iam:ListAttachedGroupPolicies",
      "iam:GetPolicyVersion",
      "iam:ListPolicies",
      "iam:GetInstanceProfile",
      "iam:ListInstanceProfiles",
      "iam:ListInstanceProfilesForRole",
      "iam:GetAccountPasswordPolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicies",
      "sts:GetCallerIdentity",
    ]

    resources = ["*"]
  }
}
