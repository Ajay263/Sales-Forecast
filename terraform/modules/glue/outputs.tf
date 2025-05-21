output "database_name" {
  description = "Name of the Glue Catalog database"
  value       = aws_glue_catalog_database.database.name
}

output "crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.s3_crawler.name
}

output "postgres_extraction_job_name" {
  description = "Name of the PostgreSQL extraction Glue job"
  value       = aws_glue_job.postgres_extraction_job.name
}

output "delta_lake_job_name" {
  description = "Name of the Delta Lake transformation Glue job"
  value       = aws_glue_job.delta_lake_job.name
}