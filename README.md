# terraform-aws-lambda-rds-s3-export

This module deploys an AWS Lambda function that automates RDS snapshot export to S3.

<!-- BEGIN_TF_DOCS -->
## Usage
```hcl
module "export" {
  source = "../../"

  namespace   = "ex"
  environment = "dev"
  name        = "export"
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket"></a> [bucket](#module\_bucket) | cloudposse/s3-bucket/aws | 4.2.0 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | cloudposse/kms-key/aws | 0.12.2 |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | rallyware/lambda-function/aws | 0.3.0 |
| <a name="module_role"></a> [role](#module\_role) | cloudposse/iam-role/aws | 0.20.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
## Resources

| Name | Type |
|------|------|
| [random_id.build](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [archive_file.build](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_allowed_kms_aliases"></a> [allowed\_kms\_aliases](#input\_allowed\_kms\_aliases) | A list of KMS aliases that are allowed to be used by the lambda function | `list(string)` | <pre>[<br>  "alias/*rds*"<br>]</pre> | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_key_deletion"></a> [key\_deletion](#input\_key\_deletion) | Duration in days after which the key is deleted after destruction of the resource | `number` | `14` | no |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | The description of the key used by an export task | `string` | `"KMS key used by an export task"` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lambda_architectures"></a> [lambda\_architectures](#input\_lambda\_architectures) | Instruction set architecture for AWS Lambda function | `list(string)` | <pre>[<br>  "arm64"<br>]</pre> | no |
| <a name="input_lambda_description"></a> [lambda\_description](#input\_lambda\_description) | Description of what the Lambda Function does | `string` | `"This Lambda function automates RDS snapshot export to S3"` | no |
| <a name="input_lambda_log_retention"></a> [lambda\_log\_retention](#input\_lambda\_log\_retention) | Specifies the number of days you want to retain log events in the specified log group | `number` | `30` | no |
| <a name="input_lambda_memory"></a> [lambda\_memory](#input\_lambda\_memory) | Amount of memory in MB the Lambda Function can use at runtime | `number` | `128` | no |
| <a name="input_lambda_policy_description"></a> [lambda\_policy\_description](#input\_lambda\_policy\_description) | The description of the IAM policy for the lambda role | `string` | `"IAM policy for role used by lambda that starts the export task"` | no |
| <a name="input_lambda_role_description"></a> [lambda\_role\_description](#input\_lambda\_role\_description) | The description of the IAM role for the lambda function | `string` | `"IAM role used by lambda that starts the export task"` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | The runtime environment for the Lambda function you are uploading | `string` | `"python3.11"` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | The amount of time the Lambda Function has to run in seconds | `number` | `5` | no |
| <a name="input_lambda_triggers"></a> [lambda\_triggers](#input\_lambda\_triggers) | Specifies which RDS snapshot events will trigger the lambda function | <pre>object({<br>    automated_cluster_snapshot_created = bool<br>    manual_cluster_snapshot_created    = bool<br>    automated_snapshot_created         = bool<br>    manual_snapshot_created            = bool<br>  })</pre> | <pre>{<br>  "automated_cluster_snapshot_created": true,<br>  "automated_snapshot_created": true,<br>  "manual_cluster_snapshot_created": false,<br>  "manual_snapshot_created": false<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | The description of the IAM role used by an export task | `string` | `"IAM role used by an export task"` | no |
| <a name="input_role_policy_description"></a> [role\_policy\_description](#input\_role\_policy\_description) | The description of the IAM policy used by an export task | `string` | `"IAM policy for the role that is used by an export task"` | no |
| <a name="input_s3_folder"></a> [s3\_folder](#input\_s3\_folder) | The Amazon S3 bucket folder to use as path of the exported data | `string` | `"instance"` | no |
| <a name="input_s3_lifecycle_rules"></a> [s3\_lifecycle\_rules](#input\_s3\_lifecycle\_rules) | A simplified list of S3 lifecycle V2 rules | <pre>list(object({<br>    enabled = optional(bool, true)<br>    id      = string<br><br>    abort_incomplete_multipart_upload_days = optional(number)<br><br>    # `filter_and` is the `and` configuration block inside the `filter` configuration.<br>    # This is the only place you should specify a prefix.<br>    filter_and = optional(object({<br>      object_size_greater_than = optional(number) # integer >= 0<br>      object_size_less_than    = optional(number) # integer >= 1<br>      prefix                   = optional(string)<br>      tags                     = optional(map(string), {})<br>    }))<br>    expiration = optional(object({<br>      date                         = optional(string) # string, RFC3339 time format, GMT<br>      days                         = optional(number) # integer > 0<br>      expired_object_delete_marker = optional(bool)<br>    }))<br>    noncurrent_version_expiration = optional(object({<br>      newer_noncurrent_versions = optional(number) # integer > 0<br>      noncurrent_days           = optional(number) # integer >= 0<br>    }))<br>    transition = optional(list(object({<br>      date          = optional(string) # string, RFC3339 time format, GMT<br>      days          = optional(number) # integer > 0<br>      storage_class = optional(string)<br>      # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.<br>    })), [])<br><br>    noncurrent_version_transition = optional(list(object({<br>      newer_noncurrent_versions = optional(number) # integer >= 0<br>      noncurrent_days           = optional(number) # integer >= 0<br>      storage_class             = optional(string)<br>      # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.<br>    })), [])<br>  }))</pre> | <pre>[<br>  {<br>    "expiration": {<br>      "days": 180<br>    },<br>    "id": "rds-s3-export-rotation",<br>    "transition": [<br>      {<br>        "days": 60,<br>        "storage_class": "GLACIER"<br>      }<br>    ]<br>  },<br>  {<br>    "abort_incomplete_multipart_upload_days": 3,<br>    "expiration": {<br>      "expired_object_delete_marker": true<br>    },<br>    "id": "rds-s3-export-delete-expiration-markers"<br>  }<br>]</pre> | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The AWS S3 bucket ARN |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The ARN of KMS key used by export task |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | The AWS Lambda function ARN |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | The AWS Lambda function role ARN |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of IAM role used by export task |
<!-- END_TF_DOCS -->

## License
The Apache-2.0 license