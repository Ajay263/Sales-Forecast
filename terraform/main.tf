provider "aws" {
  region = var.aws_region
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Create all S3 buckets
module "s3_buckets" {
  source = "./modules/s3"
  
  environment       = var.environment
  source_bucket     = var.source_bucket_name
  target_bucket     = var.target_bucket_name  # For Delta Lake
  code_bucket       = var.code_bucket_name
  
  # For S3 lifecycle policies
  lifecycle_ia_transition_days     = var.lifecycle_ia_transition_days
  lifecycle_glacier_transition_days = var.lifecycle_glacier_transition_days
  lifecycle_expiration_days        = var.lifecycle_expiration_days
  kms_deletion_window              = var.kms_deletion_window
  
  # Pass IAM roles that need access to KMS
  glue_service_role_arn = module.iam.glue_role_arn
}

# Create PostgreSQL RDS instance
module "rds" {
  source = "./modules/rds"
  
  environment         = var.environment
  db_instance_class   = var.db_instance_class
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  db_allocated_storage = var.db_allocated_storage
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  db_parameter_group_name = var.db_parameter_group_name
}

# Create DynamoDB table for ETL tracking
module "dynamodb" {
  source = "./modules/dynamodb"
  
  environment = var.environment
  table_name  = var.dynamodb_table_name
}

# Create IAM roles
module "iam" {
  source = "./modules/iam"
  
  environment        = var.environment
  s3_bucket_arns     = [
    module.s3_buckets.source_bucket_arn,
    module.s3_buckets.target_bucket_arn,
    module.s3_buckets.code_bucket_arn
  ]
  dynamodb_table_arn = module.dynamodb.table_arn
  rds_arn            = module.rds.rds_arn
}

# Create Glue resources
module "glue" {
  source = "./modules/glue"
  
  environment       = var.environment
  glue_role_arn     = module.iam.glue_role_arn
  source_bucket     = module.s3_buckets.source_bucket_name
  target_bucket     = module.s3_buckets.target_bucket_name
  code_bucket       = module.s3_buckets.code_bucket_name
  
  # Upload ETL scripts to code bucket
  db_endpoint       = module.rds.rds_endpoint
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  dynamodb_table    = module.dynamodb.table_name
}