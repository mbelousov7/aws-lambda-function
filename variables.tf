######################################## names, labels, tags ########################################
variable "labels" {
  type = object({
    prefix    = string
    stack     = string
    component = string
    env       = string
  })
  description = "Minimum required map of labels(tags) for creating aws resources"
}


variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

variable "function_name" {
  type        = string
  description = <<-EOT
      optionally define a custom value for the function name and tag=Name parameter
      in aws_lambda_function. By default, it is defined as a construction from var.labels
    EOT
  default     = "default"
}

variable "function_iam_role_name" {
  type        = string
  description = <<-EOT
      optionally define a custom value for the function iam role name and tag=Name parameter
      in aws_iam_role. By default, it is defined as a construction from var.labels
    EOT
  default     = "default"
}
######################################## iam roles and policies vars ########################################
variable "function_role_policy_arns_default" {
  description = "default arns list for function"
  default = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

variable "function_role_policy_arns" {
  type        = list(string)
  description = "A list of IAM Policy ARNs to attach to the generated function role."
  default     = []
}

variable "function_role_policy_statements" {
  type        = map(any)
  description = <<-EOT
    A `map` of zero or multiple role policies statements 
    which will be attached to task role(in addition to default)
    EOT
  default     = {}
}

variable "permissions_boundary" {
  type        = string
  description = "A permissions boundary ARN to apply to the roles that are created."
  default     = ""
}

######################################## lambda configs ########################################

variable "architectures" {
  type        = list(string)
  description = <<EOF
    Instruction set architecture for your Lambda function. Valid values are ["x86_64"] and ["arm64"]. 
    Default is ["x86_64"]. Removing this attribute, function's architecture stay the same.
  EOF
  default     = null
}

variable "description" {
  type        = string
  description = "Description of what the Lambda Function does."
  default     = null
}

variable "filename" {
  type        = string
  description = "The path to the function's deployment package within the local filesystem. If defined, The s3_-prefixed options and image_uri cannot be used."
  default     = null
}

variable "image_uri" {
  type        = string
  description = "The ECR image URI containing the function's deployment package. Conflicts with filename, s3_bucket, s3_key, and s3_object_version."
  default     = null
}

variable "s3_bucket" {
  description = <<EOF
  The S3 bucket location containing the function's deployment package. Conflicts with filename and image_uri. 
  This bucket must reside in the same AWS region where you are creating the Lambda function.
  EOF
  default     = null
  type        = string
}

variable "s3_key" {
  description = "The S3 key of an object containing the function's deployment package. Conflicts with filename and image_uri."
  default     = null
  type        = string
}

variable "s3_object_version" {
  description = "The object version containing the function's deployment package. Conflicts with filename and image_uri."
  default     = null
  type        = string
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code."
  default     = null
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB the Lambda Function can use at runtime."
  default     = 128

}

variable "package_type" {
  type        = string
  description = "The Lambda deployment package type. Valid values are Zip and Image."
  default     = "Zip"

}

variable "runtime" {
  type        = string
  description = "The runtime environment for the Lambda function you are uploading."
  default     = null

}

variable "source_code_hash" {
  type        = string
  description = <<EOF
  Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either 
  filename or s3_key. The usual way to set this is filebase64sha256('file.zip') where 'file.zip' is the local filename 
  of the lambda function source archive.
  EOF
  default     = null

}

variable "timeout" {
  type        = number
  description = "The amount of time the Lambda Function has to run in seconds."
  default     = 15

}

variable "lambda_environment" {
  type = object({
    variables = map(string)
  })
  description = "Environment (e.g. env variables) configuration for the Lambda function enable you to dynamically pass settings to your function code and libraries"
  default     = null
}

variable "vpc_config" {
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
  description = <<EOF
  Provide this to allow your function to access your VPC (if both 'subnet_ids' and 'security_group_ids' are empty then
  vpc_config is considered to be empty or unset, see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html for details).
  EOF
  default     = null
}