aws_region  = "us-east-1"
environment = "prod"

# S3 buckets configuration
source_bucket_name = "raw-data"
target_bucket_name = "delta-lake"
code_bucket_name   = "code"

# S3 lifecycle configuration
lifecycle_ia_transition_days      = 30
lifecycle_glacier_transition_days = 60
lifecycle_expiration_days         = 365
kms_deletion_window               = 7

# RDS Configuration
db_instance_class       = "db.t3.micro"
db_name                 = "ecom_db"
db_username             = "admin"
db_password             = "YourStrongPasswordHere" # Replace with actual password
db_allocated_storage    = 20
db_parameter_group_name = "default.postgres13"

# DynamoDB Configuration
dynamodb_table_name = "etl_logs"