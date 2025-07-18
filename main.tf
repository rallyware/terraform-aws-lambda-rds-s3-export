locals {
  enabled    = module.this.enabled
  lambda_src = "${path.module}/lambda"

  cloudwatch_event_patterns = {
    automated_cluster_snapshot_created = {
      name           = "auto-cluster-snapshot-created"
      detail_message = "Automated cluster snapshot created"
      detail_type    = "RDS DB Cluster Snapshot Event"
    },
    manual_cluster_snapshot_created = {
      name           = "manual-cluster-snapshot-created"
      detail_message = "Manual cluster snapshot created"
      detail_type    = "RDS DB Cluster Snapshot Event"
    },
    automated_snapshot_created = {
      name           = "auto-snapshot-created"
      detail_message = "Automated snapshot created"
      detail_type    = "RDS DB Snapshot Event"
    },
    manual_snapshot_created = {
      name           = "manual-snapshot-created"
      detail_message = "Manual snapshot created"
      detail_type    = "RDS DB Snapshot Event"
    }
  }
}

resource "random_id" "build" {
  count = local.enabled ? 1 : 0

  byte_length = 8
  keepers = {
    hash = filesha256("${local.lambda_src}/main.py")
  }
}

data "archive_file" "build" {
  count = local.enabled ? 1 : 0

  source_dir  = local.lambda_src
  output_path = "/tmp/${random_id.build[0].hex}.zip"
  type        = "zip"
}

data "aws_iam_policy_document" "lambda" {
  count = local.enabled ? 1 : 0

  version = "2012-10-17"

  statement {
    sid = "AllowExportDescribeSnapshot"
    actions = [
      "rds:StartExportTask",
      "rds:DescribeDBSnapshots",
      "rds:DescribeDBClusterSnapshots"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowGetPassRole"
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [
      module.role.arn
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowExportKeyKMS"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:RetireGrant",
    ]
    resources = [
      module.kms_key.key_arn
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowKMSByAlias"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "kms:ResourceAliases"
      values   = var.allowed_kms_aliases
    }

    resources = ["*"]
  }
}

module "lambda" {
  source  = "rallyware/lambda-function/aws"
  version = "0.3.0"

  handler       = "main.lambda_handler"
  filename      = one(data.archive_file.build[*].output_path)
  description   = var.lambda_description
  runtime       = var.lambda_runtime
  architectures = var.lambda_architectures
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout

  iam_policy_description = var.lambda_policy_description
  iam_role_description   = var.lambda_role_description
  iam_policy_documents = [
    one(data.aws_iam_policy_document.lambda[*].json)
  ]

  cloudwatch_logs_retention_in_days = var.lambda_log_retention

  cloudwatch_event_rules = [for k, v in var.lambda_triggers :
    {
      name = local.cloudwatch_event_patterns[k]["name"]
      event_pattern = jsonencode(
        {
          detail-type = [local.cloudwatch_event_patterns[k]["detail_type"]]
          detail = {
            Message = [local.cloudwatch_event_patterns[k]["detail_message"]]
          }
        }
      )
    } if v
  ]

  lambda_environment = {
    variables = {
      BACKUP_S3_BUCKET   = module.bucket.bucket_id
      BACKUP_FOLDER      = var.s3_folder
      BACKUP_KMS_KEY     = module.kms_key.key_id
      BACKUP_EXPORT_ROLE = module.role.arn
    }
  }

  context = module.this.context
}
