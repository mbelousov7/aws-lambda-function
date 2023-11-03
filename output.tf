output "arn" {
  value       = aws_lambda_function.default.arn
  description = "lambda function arn"
}

output "name" {
  value       = aws_lambda_function.default.function_name
  description = "lambda function name"
}

output "role" {
  value       = aws_lambda_function.default.role
  description = "lambda function role"
}

output "invoke_arn" {
  value       = aws_lambda_function.default.invoke_arn
  description = "ARN to be used for invoking Lambda Function from API Gateway"
}
