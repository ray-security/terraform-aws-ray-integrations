module "role" {
  source = "./modules/role"
  count  = var.enable_s3 ? 1 : 0

  name                = var.role_name
  description         = "Ray Security read-only access to S3, CloudTrail, AWS Config, Access Analyzer and IAM"
  trusted_account_arn = var.trusted_account_arn
  external_id         = var.external_id
  tags                = var.tags
}

module "s3_access" {
  source = "./modules/s3-access"
  count  = var.enable_s3 ? 1 : 0

  role_name               = module.role[0].name
  s3_bucket_names         = var.s3_bucket_names
  include_kms_permissions = var.include_kms_permissions
}

module "identity_center_role" {
  source = "./modules/role"
  count  = var.enable_identity_center ? 1 : 0

  name                = var.identity_center_role_name
  description         = "Ray Security read-only access to Identity Center, SSO Admin and Organizations"
  trusted_account_arn = var.trusted_account_arn
  external_id         = var.external_id
  tags                = var.tags
}

module "identity_center_access" {
  source = "./modules/identity-center-access"
  count  = var.enable_identity_center ? 1 : 0

  role_name = module.identity_center_role[0].name
}

module "access_analyzer" {
  source = "./modules/access-analyzer"
  count  = length(var.access_analyzer_regions) > 0 ? 1 : 0

  regions = var.access_analyzer_regions
  tags    = var.tags
}
