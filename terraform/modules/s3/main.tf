data "aws_caller_identity" "current" {}

# Source Bucket (Raw Data)
resource "aws_s3_bucket" "source_bucket" {
  bucket              = "nexabrand-${var.environment}-${var.source_bucket}"
  force_destroy       = true
}

# Enable versioning for source bucket
resource "aws_s3_bucket_versioning" "source_bucket_versioning" {
  bucket = aws_s3_bucket.source_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Target Bucket (Delta Lake)
resource "aws_s3_bucket" "target_bucket" {
  bucket              = "nexabrand-${var.environment}-${var.target_bucket}"
  force_destroy       = true
}

# Versioning target bucket
resource "aws_s3_bucket_versioning" "target_bucket_versioning" {
  bucket = aws_s3_bucket.target_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Code Bucket (for ETL scripts)
resource "aws_s3_bucket" "code_bucket" {
  bucket        = "nexabrand-${var.environment}-${var.code_bucket}"
  force_destroy = true
}

# Versioning for code bucket
resource "aws_s3_bucket_versioning" "code_bucket_versioning" {
  bucket = aws_s3_bucket.code_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# KMS key for encryption
resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.glue_service_role_arn
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:ReEncrypt*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Purpose     = "s3-encryption"
  }
}

resource "aws_kms_alias" "s3_kms_alias" {
  name          = "alias/s3-encryption-key-${var.environment}"
  target_key_id = aws_kms_key.s3_kms_key.key_id
}

# Server-Side Encryption for all buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "source_bucket_encryption" {
  bucket = aws_s3_bucket.source_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "target_bucket_encryption" {
  bucket = aws_s3_bucket.target_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "code_bucket_encryption" {
  bucket = aws_s3_bucket.code_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Lifecycle Rules for source and target buckets 
resource "aws_s3_bucket_lifecycle_configuration" "source_bucket_lifecycle" {
  bucket = aws_s3_bucket.source_bucket.id

  rule {
    id     = "transition_noncurrent_versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_ia_transition_days
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_glacier_transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_expiration_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.source_bucket_versioning]
}

resource "aws_s3_bucket_lifecycle_configuration" "target_bucket_lifecycle" {
  bucket = aws_s3_bucket.target_bucket.id

  rule {
    id     = "transition_noncurrent_versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_ia_transition_days
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_glacier_transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_expiration_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.target_bucket_versioning]
}