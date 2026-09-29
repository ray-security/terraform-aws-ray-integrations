provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

variables {
  external_id = "T2testtenant000000000000000"
}

run "defaults_create_s3_role_only" {
  command = plan

  assert {
    condition     = length(module.role) == 1 && length(module.identity_center_role) == 0 && length(module.access_analyzer) == 0
    error_message = "defaults must create only the S3 role"
  }

  assert {
    condition     = jsondecode(module.role[0].assume_role_policy).Statement[0].Principal.AWS == "arn:aws:iam::992382604000:root"
    error_message = "trust policy must name the Ray AWS account"
  }

  assert {
    condition     = jsondecode(module.role[0].assume_role_policy).Statement[0].Action == "sts:AssumeRole"
    error_message = "trust policy must allow sts:AssumeRole only"
  }

  assert {
    condition     = jsondecode(module.role[0].assume_role_policy).Statement[0].Condition.StringEquals["sts:ExternalId"] == "T2testtenant000000000000000"
    error_message = "trust policy must require the tenant External ID"
  }
}

run "custom_trusted_principal" {
  command = plan

  variables {
    trusted_account_arn = "arn:aws:iam::891377348453:root"
  }

  assert {
    condition     = jsondecode(module.role[0].assume_role_policy).Statement[0].Principal.AWS == "arn:aws:iam::891377348453:root"
    error_message = "trusted_account_arn must replace the default principal"
  }
}

run "scoped_buckets" {
  command = plan

  variables {
    s3_bucket_names = ["data-bucket", "logs-bucket"]
  }

  assert {
    condition = contains(
      flatten([for s in jsondecode(module.s3_access[0].policy_json).Statement : s.Resource if s.Sid == "S3ObjectReadAccess"]),
      "arn:aws:s3:::logs-bucket/*"
    )
    error_message = "object access must cover every listed bucket"
  }

  assert {
    condition = !contains(
      flatten([for s in jsondecode(module.s3_access[0].policy_json).Statement : s.Resource if s.Sid == "S3ObjectReadAccess"]),
      "*"
    )
    error_message = "scoped buckets must not fall back to all buckets"
  }
}

run "read_only" {
  command = plan

  variables {
    enable_identity_center = true
  }

  assert {
    condition = alltrue([
      for action in flatten([for s in jsondecode(module.s3_access[0].policy_json).Statement : s.Action if startswith(s.Sid, "S3")]) :
      can(regex("^s3:(Get|List|Describe)", action))
    ])
    error_message = "S3 statements must be read-only"
  }

  assert {
    condition = alltrue([
      for action in flatten([for s in jsondecode(module.identity_center_access[0].policy_json).Statement : s.Action]) :
      can(regex(":(Get|List|Describe|IsMemberInGroups)", action))
    ])
    error_message = "Identity Center policy must be read-only"
  }
}

run "management_account" {
  command = plan

  variables {
    enable_s3              = false
    enable_identity_center = true
  }

  assert {
    condition     = length(module.role) == 0 && length(module.identity_center_role) == 1
    error_message = "management-account run must create only the Identity Center role"
  }

  assert {
    condition     = jsondecode(module.identity_center_role[0].assume_role_policy).Statement[0].Condition.StringEquals["sts:ExternalId"] == "T2testtenant000000000000000"
    error_message = "Identity Center trust must require the tenant External ID"
  }
}

run "access_analyzer_per_region" {
  command = plan

  variables {
    access_analyzer_regions = ["us-east-1", "eu-west-1"]
  }

  assert {
    condition     = length(module.access_analyzer[0].types) == 2
    error_message = "one analyzer per region"
  }

  assert {
    condition     = module.access_analyzer[0].types["eu-west-1"] == "ACCOUNT_INTERNAL_ACCESS"
    error_message = "analyzer must be the account-internal type wiper looks for"
  }
}

run "external_id_required" {
  command = plan

  variables {
    external_id = ""
  }

  expect_failures = [var.external_id]
}

run "account_id_must_be_12_digits" {
  command = plan

  variables {
    account_id = "12345"
  }

  expect_failures = [var.account_id]
}

run "no_account_check_by_default" {
  command = plan

  assert {
    condition     = length(data.aws_caller_identity.current) == 0
    error_message = "without account_id the module must not call STS"
  }
}
