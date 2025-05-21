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

# CloudWatch Logs permissions (for Glue jobs)
resource "aws_iam_policy" "glue_logs" {
  name        = "nexabrand-${var.environment}-glue-logs"
  description = "Allow Glue to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_logs" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_logs.arn
}

# S3 access (enhanced for Glue ETL)
resource "aws_iam_policy" "s3_access" {
  name        = "nexabrand-${var.environment}-glue-s3"
  description = "Allow Glue to read/write S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Effect   = "Allow",
        Resource = concat(
          var.s3_bucket_arns,
          [for arn in var.s3_bucket_arns : "${arn}/*"]
        )
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# DynamoDB access (for Glue jobs)
resource "aws_iam_policy" "dynamodb_access" {
  name        = "nexabrand-${var.environment}-glue-dynamodb"
  description = "Allow Glue to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Effect   = "Allow",
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# RDS access (for Glue connections)
resource "aws_iam_policy" "rds_access" {
  name        = "nexabrand-${var.environment}-glue-rds"
  description = "Allow Glue to connect to RDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement"
        ],
        Effect   = "Allow",
        Resource = var.rds_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.rds_access.arn
}