output "lambda_arn" {
  value       = module.lambda.arn
  description = "The AWS Lambda function ARN"
}

output "lambda_function_name" {
  value       = module.lambda.function_name
  description = "The name of the Lambda function"
}

output "lambda_role_arn" {
  value       = module.lambda.role_arn
  description = "The AWS Lambda function role ARN"
}

output "lambda_role_name" {
  value       = module.lambda.role_name
  description = "The name of the Lambda function IAM role"
}

output "key_arn" {
  value       = module.kms_key.key_arn
  description = "The ARN of KMS key used by export task"
}

output "kms_key_id" {
  value       = module.kms_key.key_id
  description = "The ID of KMS key used by export task"
}

output "role_arn" {
  value       = module.role.arn
  description = "The ARN of IAM role used by export task"
}

output "bucket_arn" {
  value       = module.bucket.bucket_arn
  description = "The AWS S3 bucket ARN"
}

output "cloudwatch_log_group_arn" {
  value       = module.lambda.cloudwatch_log_group_arn
  description = "The ARN of the CloudWatch log group for the Lambda function"
}

output "cloudwatch_log_group_name" {
  value       = module.lambda.cloudwatch_log_group_name
  description = "The name of the CloudWatch log group for the Lambda function"
}

output "cloudwatch_event_rule_ids" {
  value       = module.lambda.cloudwatch_event_rule_ids
  description = "The IDs of the CloudWatch event rules"
}

output "cloudwatch_event_rule_arns" {
  value       = module.lambda.cloudwatch_event_rule_arns
  description = "The ARNs of the CloudWatch event rules"
}
