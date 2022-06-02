locals {

  function_name = var.function_name == "default" ? (
    "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-${var.labels.env}"
  ) : var.function_name

}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${aws_lambda_function.default.function_name}"
  retention_in_days = 30
  tags = merge(
    var.labels,
    var.tags,
    { Name = "${aws_lambda_function.default.function_name}" }
  )
}

resource "aws_lambda_function" "default" {
  //  architectures    = var.architectures
  description       = var.description
  function_name     = local.function_name
  handler           = var.handler
  memory_size       = var.memory_size
  package_type      = var.package_type
  filename          = var.filename
  image_uri         = var.image_uri
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version
  role              = aws_iam_role.function_iam_role.arn
  runtime           = var.runtime
  source_code_hash  = var.source_code_hash
  timeout           = var.timeout

  dynamic "environment" {
    for_each = var.lambda_environment != null ? [var.lambda_environment] : []
    content {
      variables = environment.value.variables
    }
  }

  tags = merge(
    var.labels,
    var.tags,
    { Name = local.function_name }
  )
}