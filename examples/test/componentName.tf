#################################################  <ENV>.tfvars  #################################################
# in the examples for modules, variables are defined and set in the same file as the module definition.
# This is done to better understand the meaning of the variables.
# In a real environment, you should define variables in a variables.tf, the values of variables depending on the environment in the <ENV name>.tfvars
variable "ENV" {
  type        = string
  description = "defines the name of the environment(dev, prod, etc). Should be defined as env variable, for example export TF_VAR_ENV=dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# in example using dev account
variable "account_number" {
  type    = string
  default = "12345678910"
}

variable "labels" {
  default = {
    prefix = "myproject"
    stack  = "stackName"
  }
}

variable "vpc_config" {
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
  default = {
    security_group_ids = ["sg-12345678901231"]
    subnet_ids         = ["subnet-1234567890"]
  }
}

variable "cloudteam_policy_names" {
  default = ["cloud-service-policy-global-deny-1", "cloud-service-policy-global-deny-2"]
}

# <ENV>.tfvars end
#################################################################################################################

#################################################  locals vars  #################################################
#if the value of a variable depends on the value of other variables, it should be defined in a locals block
locals {

  labels = merge(
    { env = var.ENV },
    { component = "lambdaName" },
    var.labels
  )

  cloudteam_policy_arns = formatlist("arn:aws:iam::${var.account_number}:policy/%s", var.cloudteam_policy_names)


}


#################################################  module config  #################################################
# In module parameters recommend use terraform variables, because:
# - values can be environment dependent
# - this ComponentName.tf file - is more for component logic description, not for values definition
# - it is better to store vars values in one or two places(<ENV>.tfvars file and variables.tf)

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "files/lambda_function.py"
  output_path = "lambda_function.zip"
}


module "lambda_function_file" {
  source           = "../.."
  runtime          = "python3.8"
  handler          = "lambda_function.lambda_handler"
  memory_size      = "256"
  timeout          = 120
  filename         = data.archive_file.lambda_zip.output_path
  depends_on       = [data.archive_file.lambda_zip]
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  lambda_environment = {
    variables = {
      ERROR_QUEUE_URL = "http://ERROR_QUEUE_URL"
      INPUT_QUEUE_URL = "http://INPUT_QUEUE_URL"
    }
  }
  vpc_config = var.vpc_config
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

module "lambda_function_image" {
  source = "../.."

  runtime      = "python3.8"
  handler      = "lambda_function.lambda_handler"
  memory_size  = "256"
  timeout      = 120
  package_type = "Image"
  image_uri    = "full-path-to-image"
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


module "lambda_function_s3" {
  source = "../.."

  runtime      = "python3.8"
  handler      = "lambda_function.lambda_handler"
  memory_size  = "256"
  timeout      = 120
  package_type = "Zip"
  s3_bucket    = "s3_bucket_name"
  s3_key       = "zip_file_s3_key"
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
