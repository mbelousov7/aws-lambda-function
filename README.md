# aws-lambda-function

Terraform module to create AWS Lambda Function .

terrafrom config example:

```
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "files/lambda_function.py"
  output_path = "lambda_function.zip"
}


module "lambda_function" {
  source = "../.."

  runtime          = "python3.8"
  handler          = "lambda_function.lambda_handler"
  memory_size      = "256"
  timeout          = 120
  filename         = data.archive_file.lambda_zip.output_path
  depends_on       = [data.archive_file.lambda_zip]
  source_code_hash = data.archive_file.lambda_zip.output_sha
  lambda_environment = {
    variables = {
      ERROR_QUEUE_URL = "http://ERROR_QUEUE_URL"
      INPUT_QUEUE_URL = "http://INPUT_QUEUE_URL"
    }
  }
  function_role_policy_statements = {
    policy-sqs = [
      {
        Action = [
          "sqs:*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:sqs:us-east-2:444455556666:queue1",
          "arn:aws:sqs:us-east-2:444455556666:queue2"
        ]
      },
    ]
  }
  labels = local.labels
}
```
more info see [examples/test](examples/test)


terraform run example
```
cd examples/test
terraform init
terraform plan
``` 

Terraform versions tested
- 0.15.3
- 1.1.8

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.function_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.function_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.function_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.function_iam_role_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_iam_policy_document.function_iam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architectures"></a> [architectures](#input\_architectures) | Instruction set architecture for your Lambda function. Valid values are ["x86\_64"] and ["arm64"]. <br>    Default is ["x86\_64"]. Removing this attribute, function's architecture stay the same. | `list(string)` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of what the Lambda Function does. | `string` | `null` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | The path to the function's deployment package within the local filesystem. If defined, The s3\_-prefixed options and image\_uri cannot be used. | `string` | `null` | no |
| <a name="input_function_iam_role_name"></a> [function\_iam\_role\_name](#input\_function\_iam\_role\_name) | optionally define a custom value for the function iam role name and tag=Name parameter<br>in aws\_iam\_role. By default, it is defined as a construction from var.labels | `string` | `"default"` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | optionally define a custom value for the function name and tag=Name parameter<br>in aws\_lambda\_function. By default, it is defined as a construction from var.labels | `string` | `"default"` | no |
| <a name="input_function_role_policy_arns"></a> [function\_role\_policy\_arns](#input\_function\_role\_policy\_arns) | A list of IAM Policy ARNs to attach to the generated function role. | `list(string)` | `[]` | no |
| <a name="input_function_role_policy_arns_default"></a> [function\_role\_policy\_arns\_default](#input\_function\_role\_policy\_arns\_default) | default arns list for function | `list` | <pre>[<br>  "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"<br>]</pre> | no |
| <a name="input_function_role_policy_statements"></a> [function\_role\_policy\_statements](#input\_function\_role\_policy\_statements) | A `map` of zero or multiple role policies statements <br>which will be attached to task role(in addition to default) | `map(any)` | `{}` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | The function entrypoint in your code. | `string` | `null` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | The ECR image URI containing the function's deployment package. Conflicts with filename, s3\_bucket, s3\_key, and s3\_object\_version. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Minimum required map of labels(tags) for creating aws resources | <pre>object({<br>    prefix    = string<br>    stack     = string<br>    component = string<br>    env       = string<br>  })</pre> | n/a | yes |
| <a name="input_lambda_environment"></a> [lambda\_environment](#input\_lambda\_environment) | Environment (e.g. env variables) configuration for the Lambda function enable you to dynamically pass settings to your function code and libraries | <pre>object({<br>    variables = map(string)<br>  })</pre> | `null` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB the Lambda Function can use at runtime. | `number` | `128` | no |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | The Lambda deployment package type. Valid values are Zip and Image. | `string` | `"Zip"` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | A permissions boundary ARN to apply to the roles that are created. | `string` | `""` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime environment for the Lambda function you are uploading. | `string` | `null` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | The S3 bucket location containing the function's deployment package. Conflicts with filename and image\_uri. <br>  This bucket must reside in the same AWS region where you are creating the Lambda function. | `string` | `null` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | The S3 key of an object containing the function's deployment package. Conflicts with filename and image\_uri. | `string` | `null` | no |
| <a name="input_s3_object_version"></a> [s3\_object\_version](#input\_s3\_object\_version) | The object version containing the function's deployment package. Conflicts with filename and image\_uri. | `string` | `null` | no |
| <a name="input_source_code_hash"></a> [source\_code\_hash](#input\_source\_code\_hash) | Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either <br>  filename or s3\_key. The usual way to set this is filebase64sha256('file.zip') where 'file.zip' is the local filename <br>  of the lambda function source archive. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The amount of time the Lambda Function has to run in seconds. | `number` | `15` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | Provide this to allow your function to access your VPC (if both 'subnet\_ids' and 'security\_group\_ids' are empty then<br>  vpc\_config is considered to be empty or unset, see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html for details). | <pre>object({<br>    security_group_ids = list(string)<br>    subnet_ids         = list(string)<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | lambda function arn |
| <a name="output_name"></a> [name](#output\_name) | lambda function name |
| <a name="output_role"></a> [role](#output\_role) | lambda function role |
<!-- END_TF_DOCS -->