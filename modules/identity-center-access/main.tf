resource "aws_iam_role_policy" "this" {
  name   = var.inline_policy_name
  role   = var.role_name
  policy = data.aws_iam_policy_document.identity_center_read_access.json
}

data "aws_iam_policy_document" "identity_center_read_access" {
  # Identity Store read permissions
  statement {
    sid    = "IdentityStoreReadAccess"
    effect = "Allow"

    actions = [
      "identitystore:DescribeGroup",
      "identitystore:DescribeGroupMembership",
      "identitystore:DescribeUser",
      "identitystore:GetGroupId",
      "identitystore:GetGroupMembershipId",
      "identitystore:GetUserId",
      "identitystore:IsMemberInGroups",
      "identitystore:ListGroupMemberships",
      "identitystore:ListGroupMembershipsForMember",
      "identitystore:ListGroups",
      "identitystore:ListUsers",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "SSOAdminReadAccess"
    effect = "Allow"

    actions = [
      "sso:DescribeAccountAssignmentCreationStatus",
      "sso:DescribeAccountAssignmentDeletionStatus",
      "sso:DescribeInstanceAccessControlAttributeConfiguration",
      "sso:DescribePermissionSet",
      "sso:DescribePermissionSetProvisioningStatus",
      "sso:DescribePermissionsPolicies",
      "sso:GetInlinePolicyForPermissionSet",
      "sso:GetPermissionsBoundaryForPermissionSet",
      "sso:GetPermissionSet",
      "sso:ListAccountAssignments",
      "sso:ListAccountAssignmentsForPrincipal",
      "sso:ListAccountsForProvisionedPermissionSet",
      "sso:ListCustomerManagedPolicyReferencesInPermissionSet",
      "sso:ListInstances",
      "sso:ListManagedPoliciesInPermissionSet",
      "sso:ListPermissionSetProvisioningStatus",
      "sso:ListPermissionSets",
      "sso:ListPermissionSetsProvisionedToAccount",
      "sso:ListTagsForResource",
      "sso:DescribeInstance",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "OrganizationsReadAccess"
    effect = "Allow"
    actions = [
      "organizations:DescribeAccount",
      "organizations:DescribeCreateAccountStatus",
      "organizations:DescribeHandshake",
      "organizations:DescribeOrganization",
      "organizations:DescribeOrganizationalUnit",
      "organizations:DescribePolicy",
      "organizations:DescribeResourcePolicy",
      "organizations:ListAccounts",
      "organizations:ListAccountsForParent",
      "organizations:ListAWSServiceAccessForOrganization",
      "organizations:ListChildren",
      "organizations:ListCreateAccountStatus",
      "organizations:ListDelegatedAdministrators",
      "organizations:ListDelegatedServicesForAccount",
      "organizations:ListHandshakesForAccount",
      "organizations:ListHandshakesForOrganization",
      "organizations:ListOrganizationalUnitsForParent",
      "organizations:ListParents",
      "organizations:ListPolicies",
      "organizations:ListPoliciesForTarget",
      "organizations:ListRoots",
      "organizations:ListTagsForResource",
      "organizations:ListTargetsForPolicy"
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
      "iam:ListPolicies"
    ]

    resources = ["*"]
  }

  # Basic STS for caller identity
  statement {
    sid    = "STSReadAccess"
    effect = "Allow"

    actions = [
      "sts:GetCallerIdentity",
    ]

    resources = ["*"]
  }
}