variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}