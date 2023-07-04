variable "region" {
    description = "is pto detector service ec2 instance deploy region"
    type = string
    default = "us-east-1"
}

# using map declaring 3 different instance types for dev, test and prod.

variable "newsletter_ec2_inst_type" {
    description = "declaring ec2 instance type for is-pto-service for dev, test and prod"
    default = "t3.small"
    }

# PEM file name to ssh into instance.
variable "is_newsletter_key_pair" {
    description = "defining the PEM key file name to ssh into ec2 instance"
    type = string
    default = "isptoservice"
}

variable "profile" {
    default = "default"
    type = string
  
}
# to declare private key path
variable "private_key_path" {
  type        = string
  description = "Path to the PEM private key file"
}
#Lambda function related variables

variable "function_name" {
    type = string
    default = "URLFilteringLambdaRohini" 
}

variable "function_handler" {
    type = string
    default = "url_filtering_lambda_rohini_lambda_handler"
}

variable "lambda_layer_name" {
    type = string
    default = "rohinilayer"  
}
variable "lambda_role_name" {
  type    = string
  default = "your-lambda-role"
}

locals{
    function_source_dir  = "${path.module}/lambdas/URLFilteringLambdaRohini/"
    requirements_directory = "${path.module}/lambdas/URLFilteringLambdaRohini/"
}
