variable "regions" {
  description = "AWS regions to create an analyzer in. Use the regions of the buckets Ray Security scans"
  type        = list(string)
}

variable "resource_types" {
  description = "Resource types the analyzer analyzes; it generates findings for these types only"
  type        = list(string)
  default     = ["AWS::S3::Bucket"]

  validation {
    condition = alltrue([
      for resource_type in var.resource_types : contains([
        "AWS::S3::Bucket",
        "AWS::S3Express::DirectoryBucket",
        "AWS::RDS::DBSnapshot",
        "AWS::RDS::DBClusterSnapshot",
        "AWS::DynamoDB::Table",
        "AWS::DynamoDB::Stream",
      ], resource_type)
    ])
    error_message = "Internal access analyzers support only AWS::S3::Bucket, AWS::S3Express::DirectoryBucket, AWS::RDS::DBSnapshot, AWS::RDS::DBClusterSnapshot, AWS::DynamoDB::Table and AWS::DynamoDB::Stream."
  }
}

variable "tags" {
  description = "Tags to apply to the analyzers"
  type        = map(string)
  default     = {}
}
