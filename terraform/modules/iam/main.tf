# IAM role for AWS Glue
resource "aws_iam_role" "glue_role" {
  name = "nexabrand-${var.environment}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Attach AWS managed policy for Glue
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# CloudWatch Logs permissions (for Glue job logs)
resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "nexabrand-${var.environment}-cloudwatch-logs"
  description = "Policy for CloudWatch Logs access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:AssociateKmsKey"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# Enhanced S3 access policy
resource "aws_iam_policy" "s3_access" {
  name        = "nexabrand-${var.environment}-s3-access"
  description = "Policy for S3 bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Effect   = "Allow"
        Resource = concat(
          var.s3_bucket_arns,
          [for bucket_arn in var.s3_bucket_arns : "${bucket_arn}/*"]
        )
      }
    ]
  })
}

# Attach S3 access policy
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# Enhanced DynamoDB access policy
resource "aws_iam_policy" "dynamodb_access" {
  name        = "nexabrand-${var.environment}-dynamodb-access"
  description = "Policy for DynamoDB table access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable"
        ]
        Effect   = "Allow"
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
      }
    ]
  })
}

# Attach DynamoDB access policy
resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# Enhanced RDS access policy
resource "aws_iam_policy" "rds_access" {
  name        = "nexabrand-${var.environment}-rds-access"
  description = "Policy for RDS instance access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBClusterParameters",
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ]
        Effect   = "Allow"
        Resource = var.rds_arn
      },
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = var.rds_secret_arn # Add this variable if using Secrets Manager
      }
    ]
  })
}

# Attach RDS access policy
resource "aws_iam_role_policy_attachment" "rds_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.rds_access.arn
}

# KMS permissions if using encrypted resources
resource "aws_iam_policy" "kms_access" {
  count       = var.kms_key_arn != null ? 1 : 0
  name        = "nexabrand-${var.environment}-kms-access"
  description = "Policy for KMS access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Effect   = "Allow"
        Resource = var.kms_key_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kms_access" {
  count      = var.kms_key_arn != null ? 1 : 0
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.kms_access[0].arn
}