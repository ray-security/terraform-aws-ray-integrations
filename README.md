# Ray Security AWS integration

Creates the read-only IAM roles Ray Security uses to scan your AWS accounts. You run it with your own AWS
credentials; Ray Security never receives them. Each role trusts the Ray Security AWS account only when it
presents your **External ID**, shown on the Ray Security S3 setup screen.

| Part | Where you apply it | What Ray Security reads |
|---|---|---|
| S3 role (`RaySecurityRole`, on by default) | every AWS account Ray Security scans | S3 buckets and objects, bucket access settings, IAM users/roles/groups, Access Analyzer findings, access logs |
| Identity Center role (`enable_identity_center`) | your AWS Organizations management account, once | Identity Center users, groups, permission sets and account assignments |
| Access Analyzer (`access_analyzer_regions`) | the scanned accounts, optional | who can access each bucket |

The whole install is: install Terraform, sign in to AWS, choose where Terraform keeps its state, paste one file,
run the commands. About 10 minutes.

---

## Step 1 — Install Terraform (1.11 or later)

**macOS**

```sh
brew install terraform
```

**Windows** (PowerShell)

```powershell
winget install --id Hashicorp.Terraform -e
```

Then close and reopen PowerShell. Without `winget`, download the zip from
<https://developer.hashicorp.com/terraform/install>, unzip `terraform.exe` into a folder on your `PATH`.

**Linux:** follow <https://developer.hashicorp.com/terraform/install> (apt and yum repositories).

**AWS CloudShell:** it has AWS credentials already but no Terraform. Install it in your home directory:

```sh
curl -fsSLO https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_linux_amd64.zip
unzip terraform_1.11.4_linux_amd64.zip -d ~/bin && export PATH=~/bin:$PATH
```

**Check:**

```sh
terraform version
```

You should see `Terraform v1.11` or newer. Use Terraform, not OpenTofu: `tofu` looks modules up in its own registry, where this module is not published.

## Step 2 — Sign in to the AWS account

Terraform uses the same credentials as the AWS CLI. Pick the way your company gives you AWS access.

- **SSO (a sign-in portal like `https://<company>.awsapps.com/start`):** `aws configure sso`, then `aws sso login`.
- **Access keys:** `aws configure`, then paste the access key ID and secret.
- **AWS CloudShell:** nothing to do.

If you named the profile something other than `default`, tell Terraform which one to use:

```sh
export AWS_PROFILE=<profile>          # macOS, Linux, CloudShell
```

```powershell
$env:AWS_PROFILE = "<profile>"        # Windows PowerShell
```

**Check** that you are in the account you mean to change:

```sh
aws sts get-caller-identity
```

You need rights to create IAM roles and inline policies (and Access Analyzer, if you enable it).

## Step 3 — Choose where Terraform keeps its state

Terraform records what it created in a state file. It needs that file to change or remove the role later, so
keep it somewhere your team can reach. The setup screen asks this per account and writes the matching block.

| Choice | What to do |
|---|---|
| **An S3 bucket you already have** (recommended) | Nothing extra. Use the `backend "s3"` block below with your bucket and its region |
| **A new S3 bucket** | Run the two `aws s3api` commands in step 5 before `terraform init`. The bucket is `ray-security-tfstate-<account>` |
| **This folder** | Delete the `backend "s3"` block. Keep the folder: the state is the `terraform.tfstate` file in it |

`use_lockfile = true` locks the state with a small `.tflock` file next to it in the same bucket, so two people
cannot apply at once. It needs Terraform 1.11 or later and no DynamoDB table.

## Step 4 — Create `main.tf`

Make an empty folder and save this as `main.tf`. The Ray Security setup screen shows the same file with your
External ID already filled in; copy it from there if you can.

```hcl
terraform {
  required_version = ">= 1.11.0"

  backend "s3" {
    bucket       = "my-terraform-state"                  # your state bucket
    key          = "ray-security/123456789012.tfstate"   # one file per account
    region       = "us-east-1"                           # the state bucket's region
    use_lockfile = true
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["123456789012"]   # the account to change
}

module "ray_security" {
  source  = "ray-security/ray-integrations/aws"
  version = "~> 1.1"

  account_id  = "123456789012"   # the same account
  external_id = "REPLACE_ME"     # from the Ray Security S3 setup screen

  # Optional:
  # s3_bucket_names         = ["my-data-bucket", "my-logs-bucket"]  # default: all buckets
  # include_kms_permissions = true                                   # SSE-KMS objects or log files
  # access_analyzer_regions = ["us-east-1"]                          # your buckets' regions; AWS charges for it
  # enable_identity_center  = true                                   # management account only
}
```

Both account lines stop Terraform when you are signed in to a different account, before it changes anything.
`allowed_account_ids` stops it earliest; `account_id` also names the account in the error.

Downloaded this repository instead? Use [`examples/basic/main.tf`](examples/basic/main.tf): edit `REPLACE_ME`
and run the commands below in that folder.

## Step 5 — Apply

Run in the folder with `main.tf`, one line at a time. The commands are the same in bash, zsh, PowerShell and
cmd. The first one must show the account from `main.tf` in its `Account` field.

```sh
aws sts get-caller-identity
terraform init
terraform apply
```

Chose **a new S3 bucket**? Run these two after `aws sts get-caller-identity` and before `terraform init`. Outside
`us-east-1`, add `--create-bucket-configuration LocationConstraint=<region>` to the first one; in `us-east-1`,
leave it out. AWS blocks public access and encrypts new buckets by default.

```sh
aws s3api create-bucket --bucket ray-security-tfstate-123456789012 --region us-east-1
aws s3api put-bucket-versioning --bucket ray-security-tfstate-123456789012 --region us-east-1 --versioning-configuration Status=Enabled
```

Terraform lists what it will create and asks you to type `yes`. It ends with `Apply complete!`.

## Step 6 — Connect in Ray Security

On the S3 setup screen, enter the 12-digit AWS account ID you applied in and press **Test
connection**. IAM changes can take a few seconds to apply; retry once if the first test fails.

Test connection assumes the role once with your External ID, and twice more without it and with a wrong
one. Those two are expected to fail and appear in CloudTrail as denied `AssumeRole` calls from Ray Security.

---

## More accounts

- **Each account Ray Security scans:** repeat steps 2–5 in a new folder (or a new Terraform workspace), signed
  in to that account.
- **Identity Center:** once, signed in to the management account, with `enable_identity_center = true`. Set
  `enable_s3 = false` unless Ray Security also scans that account.
- **Your own pipeline:** the module is an ordinary Terraform module; add the `module` block to your existing
  configuration.

## Before you connect access logs

Ray Security reads CloudTrail log files and S3 server access logs **from the bucket they are written to**.

- If you set `s3_bucket_names`, include that logs bucket.
- Object reads and writes appear in CloudTrail only when S3 **data events** are enabled on the trail. AWS
  charges for data events.
- SSE-KMS encrypted log files need `include_kms_permissions = true`.

## Update or remove

Terraform needs its state to change or remove what it created. With the S3 backend, any folder with the same
`main.tf` finds it after `terraform init`. Without it, keep the folder with `main.tf` and `terraform.tfstate`.
Change a value and run `terraform apply` again, or remove everything with:

```sh
terraform destroy
```

## Troubleshooting

| Message | What it means | Fix |
|---|---|---|
| `Error acquiring the state lock` with `StatusCode: 403` / `AccessDenied` | You are signed in to an account that cannot read the state bucket, usually the wrong account | Check `aws sts get-caller-identity`, sign in to the right account, run again |
| `Error acquiring the state lock` with `StatusCode: 412` / `PreconditionFailed` | Someone else is applying now; `Who` names them | Wait and run again. Use `terraform force-unlock <ID>` only if that run crashed |
| `AWS account ID not allowed: <id>` | Signed in to a different account than `allowed_account_ids` | Sign in to the account in `main.tf`, run again. Nothing was changed |
| `Unsupported Terraform Core version` | Terraform is older than 1.11 | Install 1.11 or later (step 1) |
| `EntityAlreadyExists` on `terraform apply` | The role exists but is missing from the state, for example after an apply under the wrong account | `terraform import 'module.ray_security.module.role[0].aws_iam_role.this' RaySecurityRole`, then apply again |

## Inputs

| Name | Description | Default |
|---|---|---|
| `external_id` | External ID from the Ray Security S3 setup screen | required |
| `account_id` | account this configuration is for; plan fails under other credentials | `null` (no check) |
| `trusted_account_arn` | AWS principal allowed to assume the roles; change only if the setup screen shows another | `arn:aws:iam::992382604000:root` |
| `enable_s3` | create the S3 scanning role | `true` |
| `role_name` | name of the S3 scanning role | `RaySecurityRole` |
| `s3_bucket_names` | buckets Ray Security may read; empty = all | `[]` |
| `include_kms_permissions` | allow SSE-KMS decrypt | `false` |
| `enable_identity_center` | create the Identity Center role (management account only) | `false` |
| `identity_center_role_name` | name of the Identity Center role | `RaySecurityIdentityCenterRole` |
| `access_analyzer_regions` | regions to create an account-internal Access Analyzer in; empty = none | `[]` |
| `tags` | tags on every resource | `{}` |

## Outputs

| Name | Description |
|---|---|
| `role_arn` | ARN of the S3 scanning role |
| `identity_center_role_arn` | ARN of the Identity Center role |
| `access_analyzer_arns` | Access Analyzer ARNs by region |

## Submodules

| Module | Creates |
|---|---|
| [`modules/role`](modules/role) | an IAM role that trusts the Ray Security AWS account with your External ID |
| [`modules/s3-access`](modules/s3-access) | the read-only inline policy for S3, KMS, IAM, CloudTrail, AWS Config and Access Analyzer |
| [`modules/identity-center-access`](modules/identity-center-access) | the read-only inline policy for Identity Store, SSO Admin and Organizations |
| [`modules/access-analyzer`](modules/access-analyzer) | an account-internal analyzer per region, analyzing S3 buckets only |
