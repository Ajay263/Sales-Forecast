variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# S3 variables
variable "source_bucket_name" {
  description = "Name of the S3 bucket for raw data"
  type        = string
  default     = "raw-data"
}

variable "target_bucket_name" {
  description = "Name of the S3 bucket for Delta Lake data"
  type        = string
  default     = "delta-lake"
}

variable "code_bucket_name" {
  description = "Name of the S3 bucket for storing ETL scripts"
  type        = string
  default     = "etl-code"
}

variable "lifecycle_ia_transition_days" {
  description = "Days after which objects transition to IA storage"
  type        = number
  default     = 30
}

variable "lifecycle_glacier_transition_days" {
  description = "Days after which objects transition to Glacier storage"
  type        = number
  default     = 60
}

variable "lifecycle_expiration_days" {
  description = "Days after which objects expire"
  type        = number
  default     = 365
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
}

# RDS variables
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "ecom_db"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS (in GB)"
  type        = number
  default     = 20
}

variable "db_subnet_group_name" {
  description = "RDS subnet group name"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs for RDS"
  type        = list(string)
  default     = []
}

variable "db_parameter_group_name" {
  description = "RDS parameter group name"
  type        = string
  default     = "default.postgres13"
}

# DynamoDB variables
variable "dynamodb_table_name" {
  description = "Name of DynamoDB table for ETL tracking"
  type        = string
  default     = "etl_logs"
}