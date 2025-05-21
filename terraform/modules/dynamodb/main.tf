# DynamoDB table for ETL tracking
resource "aws_dynamodb_table" "etl_tracking" {
  name           = "${var.environment}-${var.table_name}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "table_name"
  range_key      = "filter_column"

  attribute {
    name = "table_name"
    type = "S"
  }

  attribute {
    name = "filter_column"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "${var.environment}-${var.table_name}"
    Environment = var.environment
  }
}