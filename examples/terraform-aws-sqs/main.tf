provider "aws" {
  region = "${var.aws_region}"
}


resource "aws_sqs_queue" "pto_detector_queue_test" {
  name                      = "pto-detector-queue-test"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}
