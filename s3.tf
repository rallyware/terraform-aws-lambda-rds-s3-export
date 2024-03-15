module "bucket" {
  source             = "cloudposse/s3-bucket/aws"
  version            = "4.0.1"
  sse_algorithm      = "aws:kms"
  kms_master_key_arn = module.kms_key.key_arn

  lifecycle_configuration_rules = flatten([
    for rule in var.s3_lifecycle_rules :
    rule.enabled ? [{
      enabled = true
      id      = "rds-s3-export-expiration"

      abort_incomplete_multipart_upload_days = 3

      filter_and = null

      expiration = rule.expiration_days > 0 ? {
        days = rule.expiration_days
      } : {}

      transition = rule.glacier_transition_days > 0 ? [{
        days          = rule.glacier_transition_days
        storage_class = "GLACIER"
      }] : []

      noncurrent_version_expiration = rule.noncurrent_expiration_days > 0 ? {
        noncurrent_days = rule.noncurrent_expiration_days
      } : {}

      noncurrent_version_transition = []
    }] : []
  ])

  context = module.this.context
}
