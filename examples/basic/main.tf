# Ray Security AWS integration.
# Edit the REPLACE_ME value, then run: terraform init && terraform apply
# See ../../README.md for the step-by-step guide.

terraform {
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "us-east-1"
}

module "ray_security" {
  # Downloaded this repository? Keep "../../".
  # Writing your own main.tf? Use source = "ray-security/ray-integrations/aws" and version = "~> 1.0".
  source = "../../"

  # ---------- Required ----------

  # The External ID shown on the Ray Security S3 setup screen.
  external_id = "REPLACE_ME"

  # ---------- Optional (uncomment to change) ----------

  # Only these buckets (default: all). Include the bucket your CloudTrail and S3 access logs go to.
  # s3_bucket_names = ["my-data-bucket", "my-logs-bucket"]

  # Your objects or log files are encrypted with SSE-KMS.
  # include_kms_permissions = true

  # Show who can access each bucket. Creates an Access Analyzer per region (AWS charges for it).
  # access_analyzer_regions = ["us-east-1"]

  # Only in your AWS Organizations management account, if you use Identity Center.
  # enable_identity_center = true
}

output "role_arn" {
  description = "Enter the 12-digit account ID from this ARN on the Ray Security S3 setup screen"
  value       = module.ray_security.role_arn
}
