output "glue_role_arn" {
  description = "ARN of the IAM role for Glue"
  value       = aws_iam_role.glue_role.arn
}

output "glue_role_name" {
  description = "Name of the IAM role for Glue"
  value       = aws_iam_role.glue_role.name
}