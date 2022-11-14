output "arn" {
  value       = aws_sqs_queue.pto_detector_queue_test.*.arn
  description = "The ARN of the SQS queue."
}
