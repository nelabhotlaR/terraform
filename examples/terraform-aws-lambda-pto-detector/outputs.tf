output "arn" {
  value       = aws_lambda_layer_version.lambda_layer.*.arn
  description = "The ARN of the lambda layer"
}

output "lambda_function"{
	value	= aws_lambda_function.lambda.function_name
	description = "Funtion name of lambda"
}
