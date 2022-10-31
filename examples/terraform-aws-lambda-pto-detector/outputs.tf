output "arn" {
  value       = aws_lambda_layer_version.lambda_layer.*.arn
  description = "The ARN of the lambda layer"
}
