output "source_bucket_name" {
  description = "Name of the source bucket"
  value       = aws_s3_bucket.source_bucket.bucket
}

output "target_bucket_name" {
  description = "Name of the target bucket"
  value       = aws_s3_bucket.target_bucket.bucket
}

output "code_bucket_name" {
  description = "Name of the code bucket"
  value       = aws_s3_bucket.code_bucket.bucket
}

output "source_bucket_arn" {
  description = "ARN of the source bucket"
  value       = aws_s3_bucket.source_bucket.arn
}

output "target_bucket_arn" {
  description = "ARN of the target bucket"
  value       = aws_s3_bucket.target_bucket.arn
}

output "code_bucket_arn" {
  description = "ARN of the code bucket"
  value       = aws_s3_bucket.code_bucket.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for S3 encryption"
  value       = aws_kms_key.s3_kms_key.arn
}