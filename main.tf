locals {
  partition = data.aws_partition.current.partition
}

data "aws_partition" "current" {}

module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.2"

  description             = var.key_description
  deletion_window_in_days = var.key_deletion

  context = module.this.context
}

module "bucket" {
  source             = "cloudposse/s3-bucket/aws"
  version            = "4.11.0"
  sse_algorithm      = "aws:kms"
  kms_master_key_arn = module.kms_key.key_arn

  lifecycle_configuration_rules = var.s3_lifecycle_rules

  context = module.this.context
}

data "aws_iam_policy_document" "task" {
  count = local.enabled ? 1 : 0

  statement {
    sid = "AllowS3"
    actions = [
      "s3:PutObject*",
      "s3:ListBucket",
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:${local.partition}:s3:::${module.bucket.bucket_id}",
      "arn:${local.partition}:s3:::${module.bucket.bucket_id}/*"
    ]
    effect = "Allow"
  }
}

module "role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.23.0"

  role_description      = var.role_description
  policy_description    = var.role_policy_description
  policy_document_count = 1
  policy_documents = [
    one(data.aws_iam_policy_document.task[*].json)
  ]

  principals = {
    "Service" : ["export.rds.amazonaws.com"]
  }

  attributes = concat(module.this.attributes, ["task"])

  context = module.this.context
}
