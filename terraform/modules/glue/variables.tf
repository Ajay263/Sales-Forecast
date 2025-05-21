variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "glue_role_arn" {
  description = "ARN of the IAM role for Glue"
  type        = string
}

variable "source_bucket" {
  description = "Name of the S3 bucket for raw data"
  type        = string
}

variable "target_bucket" {
  description = "Name of the S3 bucket for Delta Lake data"
  type        = string
}

variable "code_bucket" {
  description = "Name of the S3 bucket for ETL scripts"
  type        = string
}

variable "db_endpoint" {
  description = "RDS endpoint"
  type        = string
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "db_username" {
  description = "RDS username"
  type        = string
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}

variable "dynamodb_table" {
  description = "Name of the DynamoDB table for ETL tracking"
  type        = string
}