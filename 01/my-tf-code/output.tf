output "api_gateway_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api_gateway.arn}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.api_gateway_stage_name}"
}

output "lambda_arn" {
  value = aws_lambda_function.lambda_function.arn
}

