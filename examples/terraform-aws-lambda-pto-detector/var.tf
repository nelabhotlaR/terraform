variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-south-1"
}

variable "function_name"{
    description = "Lamda function name"
    type        = string
    default     = "pto_detector_dummy1"
}

variable "handler"{
    description = "lambda handler name"
    type        = string
    default     = "pto_detector_dummy.lambda_handler"
}

locals{
    input_file  = "${path.module}/lambdas/downloaded_lambda.py"
    requirements_directory = "${path.module}/lambdas/requirements"
}

variable "lambda_layer_name"{
    description = "name of lambda layer"
    type        = string
    default     = "pto_detector_layer"
}

variable "lambda_download_url"{
    description = "lambda url"
    type        = string
    default     = "https://raw.githubusercontent.com/qxf2/qxf2-lambdas/master/holiday_reminder/holiday_reminder.py"
}

variable "requirements_download_url"{
    description = "requirements file url"
    type        = string
    default     = "https://raw.githubusercontent.com/qxf2/qxf2-lambdas/master/holiday_reminder/requirements.txt"
}