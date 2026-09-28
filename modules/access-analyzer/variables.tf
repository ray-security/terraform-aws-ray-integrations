variable "regions" {
  description = "AWS regions to create an analyzer in. Use the regions of the buckets Ray Security scans"
  type        = list(string)
}

variable "resource_types" {
  description = "Resource types to keep findings for; findings for every other type are archived. Valid types: AWS::S3::Bucket, AWS::IAM::Role, AWS::KMS::Key, AWS::Lambda::Function, AWS::SQS::Queue, AWS::SecretsManager::Secret, AWS::SNS::Topic, AWS::EFS::FileSystem, AWS::EC2::Snapshot, AWS::ECR::Repository, AWS::RDS::DBSnapshot, AWS::RDS::DBClusterSnapshot, AWS::DynamoDB::Table, AWS::DynamoDB::Stream"
  type        = list(string)
  default     = ["AWS::S3::Bucket"]
}

variable "tags" {
  description = "Tags to apply to the analyzers"
  type        = map(string)
  default     = {}
}
