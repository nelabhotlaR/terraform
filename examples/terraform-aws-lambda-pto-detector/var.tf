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
    default     = "pto_detector_dummy.main_handler"
}

locals{
    input_file  = "${path.module}/lambdas/pto_detector_dummy/pto_detector_dummy.py"
    requirements_directory = "${path.module}/lambdas/pto_detector_dummy/requirements"
}

variable "lambda_layer_name"{
    description = "name of lambda layer"
    type        = string
    default     = "pto_detector_layer"
}
