# Glue Catalog Database
resource "aws_glue_catalog_database" "database" {
  name        = "nexabrand-${var.environment}-database"
  description = "Database for ${var.environment} environment data"
}

# Glue Crawler to catalog S3 data
resource "aws_glue_crawler" "s3_crawler" {
  name          = "nexabrand-${var.environment}-s3-crawler"
  database_name = aws_glue_catalog_database.database.name
  role          = var.glue_role_arn
  
  s3_target {
    path = "s3://${var.source_bucket}/"
  }
  
  schema_change_policy {
    delete_behavior = "LOG"
  }
  
  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })
  
  tags = {
    Environment = var.environment
    Service     = "glue"
  }
}

# ETL Python Script for RDS to S3 extraction
resource "aws_s3_object" "postgres_extraction_script" {
  bucket  = var.code_bucket
  key     = "scripts/postgres-extraction-job.py"
  content = templatefile("${path.module}/scripts/postgres-extraction-job.py", {
    db_endpoint      = var.db_endpoint
    db_name          = var.db_name
    db_username      = var.db_username
    db_password      = var.db_password
    s3_bucket        = var.source_bucket
    dynamo_table     = var.dynamodb_table
  })
  
  content_type = "text/x-python"
}

# Delta Lake transformation script
resource "aws_s3_object" "delta_lake_script" {
  bucket  = var.code_bucket
  key     = "scripts/delta-lake-transformation.py"
  content = templatefile("${path.module}/scripts/delta-lake-transformation.py", {
    source_bucket = var.source_bucket
    target_bucket = var.target_bucket
  })
  
  content_type = "text/x-python"
}

# Delta Lake JAR file
resource "aws_s3_object" "delta_lake_jar" {
  bucket = var.code_bucket
  key    = "jars/delta-core_2.12-1.0.0.jar"
  source = "${path.module}/jars/delta-core_2.12-1.0.0.jar"
}

# Glue Job for RDS to S3 extraction
resource "aws_glue_job" "postgres_extraction_job" {
  name              = "nexabrand-${var.environment}-postgres-extraction"
  role_arn          = var.glue_role_arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 2880
  max_retries       = 1
  
  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${var.code_bucket}/scripts/postgres-extraction-job.py"
  }
  
  default_arguments = {
    "--enable-metrics"                   = "true"
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-disable"
  }
  
  execution_property {
    max_concurrent_runs = 1
  }
  
  tags = {
    Environment = var.environment
    Service     = "glue"
  }
}

# Glue Job for Delta Lake transformation
resource "aws_glue_job" "delta_lake_job" {
  name              = "nexabrand-${var.environment}-delta-lake-transformation"
  role_arn          = var.glue_role_arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 2880
  max_retries       = 1
  
  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${var.code_bucket}/scripts/delta-lake-transformation.py"
  }
  
  default_arguments = {
    "--enable-metrics"                   = "true"
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--extra-jars"                       = "s3://${var.code_bucket}/jars/delta-core_2.12-1.0.0.jar"
    "--conf"                             = "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
    "--source-bucket"                    = var.source_bucket
    "--target-bucket"                    = var.target_bucket
  }
  
  execution_property {
    max_concurrent_runs = 1
  }
  
  tags = {
    Environment = var.environment
    Service     = "glue"
  }
}