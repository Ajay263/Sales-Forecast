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

# Custom policy for S3 access
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
          "s3:ListBucket"
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

# Custom policy for DynamoDB access
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
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

# Attach DynamoDB access policy
resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# Custom policy for RDS access
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
          "rds-data:BatchExecuteStatement"
        ]
        Effect   = "Allow"
        Resource = var.rds_arn
      }
    ]
  })
}

# Attach RDS access policy
resource "aws_iam_role_policy_attachment" "rds_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.rds_access.arn
}