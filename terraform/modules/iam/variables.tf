variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "s3_bucket_arns" {
  description = "ARNs of S3 buckets to allow access to"
  type        = list(string)
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table to allow access to"
  type        = string
}

variable "rds_arn" {
  description = "ARN of the RDS instance to allow access to"
  type        = string
}