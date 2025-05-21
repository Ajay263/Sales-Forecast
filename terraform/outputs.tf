output "rds_endpoint" {
  description = "Endpoint of the PostgreSQL RDS instance"
  value       = module.rds.rds_endpoint
}

output "source_bucket" {
  description = "Name of the S3 bucket for raw data"
  value       = module.s3_buckets.source_bucket_name
}

output "target_bucket" {
  description = "Name of the S3 bucket for Delta Lake data"
  value       = module.s3_buckets.target_bucket_name
}

output "code_bucket" {
  description = "Name of the S3 bucket for ETL scripts"
  value       = module.s3_buckets.code_bucket_name
}

output "dynamodb_table" {
  description = "Name of the DynamoDB table for ETL tracking"
  value       = module.dynamodb.table_name
}

output "glue_database" {
  description = "Name of the Glue Catalog database"
  value       = module.glue.database_name
}

output "glue_extraction_job" {
  description = "Name of the PostgreSQL extraction Glue job"
  value       = module.glue.postgres_extraction_job_name
}

output "glue_delta_lake_job" {
  description = "Name of the Delta Lake transformation Glue job"
  value       = module.glue.delta_lake_job_name
}