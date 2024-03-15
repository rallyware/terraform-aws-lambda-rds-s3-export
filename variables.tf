variable "lambda_runtime" {
  type        = string
  default     = "python3.11"
  description = "The runtime environment for the Lambda function you are uploading"
}

variable "lambda_architectures" {
  type        = list(string)
  default     = ["arm64"]
  description = "Instruction set architecture for AWS Lambda function"
}

variable "lambda_timeout" {
  type        = number
  default     = 5
  description = "The amount of time the Lambda Function has to run in seconds"
}

variable "lambda_memory" {
  type        = number
  default     = 128
  description = "Amount of memory in MB the Lambda Function can use at runtime"
}

variable "lambda_description" {
  type        = string
  default     = "This Lambda function automates RDS snapshot export to S3"
  description = "Description of what the Lambda Function does"
}

variable "lambda_log_retention" {
  type        = number
  default     = 30
  description = "Specifies the number of days you want to retain log events in the specified log group"
}

variable "lambda_policy_description" {
  type        = string
  default     = "IAM policy for role used by lambda that starts the export task"
  description = "The description of the IAM policy for the lambda role"
}

variable "lambda_role_description" {
  type        = string
  default     = "IAM role used by lambda that starts the export task"
  description = "The description of the IAM role for the lambda function"
}

variable "lambda_triggers" {
  type = object({
    automated_cluster_snapshot_created = bool
    manual_cluster_snapshot_created    = bool
    automated_snapshot_created         = bool
    manual_snapshot_created            = bool
  })
  default = {
    automated_cluster_snapshot_created = true
    manual_cluster_snapshot_created    = false
    automated_snapshot_created         = true
    manual_snapshot_created            = false
  }
  description = "Specifies which RDS snapshot events will trigger the lambda function"
}

variable "s3_folder" {
  type        = string
  default     = "instance"
  description = "The Amazon S3 bucket folder to use as path of the exported data"
}

variable "s3_lifecycle_rules" {
  type = list(object({
    enabled                                = optional(bool, true)
    id                                     = optional(string)
    abort_incomplete_multipart_upload_days = optional(number)

    filter_and = optional(object({
      object_size_greater_than = optional(number)
      object_size_less_than    = optional(number)
      prefix                   = optional(string)
      tags                     = optional(map(string), {})
    }))

    expiration = optional(object({
      date = optional(string)
      days = optional(number)
    }))

    expired_object_delete_marker = optional(bool)

    noncurrent_version_expiration = optional(object({
      newer_noncurrent_versions = optional(number)
      noncurrent_days           = optional(number)
    }))

    transition = optional(list(object({
      date          = optional(string)
      days          = optional(number)
      storage_class = optional(string)
    })))

    noncurrent_version_transition = optional(list(object({
      newer_noncurrent_versions = optional(number)
      noncurrent_days           = optional(number)
      storage_class             = optional(string)
    })))
  }))
  default = [
    {
      id = "rds-s3-export-rotation"
      expiration = {
        days = 180
      }
      transition = [
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
    },
    {
      id                                     = "rds-s3-export-delete-expiration-markers"
      expired_object_delete_marker           = true
      abort_incomplete_multipart_upload_days = 3
    }
  ]
  description = "A simplified list of S3 lifecycle V2 rules"
  nullable    = false
}

variable "key_deletion" {
  type        = number
  default     = 14
  description = "Duration in days after which the key is deleted after destruction of the resource"
}

variable "key_description" {
  type        = string
  default     = "KMS key used by an export task"
  description = "The description of the key used by an export task"
}

variable "role_description" {
  type        = string
  default     = "IAM role used by an export task"
  description = "The description of the IAM role used by an export task"
}

variable "role_policy_description" {
  type        = string
  default     = "IAM policy for the role that is used by an export task"
  description = "The description of the IAM policy used by an export task"
}

variable "allowed_kms_aliases" {
  type        = list(string)
  default     = ["alias/*rds*"]
  description = "A list of KMS aliases that are allowed to be used by the lambda function"
}
