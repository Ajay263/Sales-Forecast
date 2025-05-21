variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "source_bucket" {
  description = "Source bucket name suffix"
  type        = string
}

variable "target_bucket" {
  description = "Target bucket name suffix"
  type        = string
}

variable "code_bucket" {
  description = "Code bucket name suffix"
  type        = string
}

variable "lifecycle_ia_transition_days" {
  description = "Days after which objects transition to IA storage"
  type        = number
}

variable "lifecycle_glacier_transition_days" {
  description = "Days after which objects transition to Glacier storage"
  type        = number
}

variable "lifecycle_expiration_days" {
  description = "Days after which objects expire"
  type        = number
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
}

variable "glue_service_role_arn" {
  description = "ARN of the Glue service role that needs KMS permissions"
  type        = string
}