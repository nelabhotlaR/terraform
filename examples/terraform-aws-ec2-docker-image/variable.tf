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
    default = "personal"
    type = string
  
}
# to declare private key path
variable "private_key_path" {
  type        = string
  description = "Path to the PEM private key file"
}


#Lambda function related variables
variable "clone_repository" {
  type = bool
  default = false
}

variable "github_repo" {
  type    = string
  default = "git hub repo"
}

variable "github_repo_name" {
  type    = string
  default = "you_github_repo_name"
}


variable "lambda_function_name" {
  type    = string
  default = "your-lambda-function"
}

variable "lambda_handler" {
  type    = string
  default = "lambda_function.handler"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.9"
}

variable "lambda_filename" {
  type    = string
  default = "lambda_code.zip"
}

variable "lambda_role_name" {
  type    = string
  default = "your-lambda-role"
}

variable "lambda_layer_name" {
    type = string
    default = "urlfilter-layer"  
}

locals{
    function_source_dir  = "/tmp/qxf2-lambdas/URLFilteringLambdaRohini/"
    requirements_directory = "/tmp/qxf2-lambdas/URLFilteringLambdaRohini/"
}

variable "CHATGPT_API_KEY" {
  type = string
  default = "chat gpt api key value"
}

variable "CHATGPT_VERSION" {
  type = string
  default = "gpt-3.5-turbo"
}

 variable "API_KEY_VALUE" {
  type = string
  default = "api key value"
 }

 variable "employee_list" {
  description = "List of employee names"
  type        = list(string)
  default     = ["Raji","Mohan","Akkul","Drishya","Raghava","Shiva","Indira","RohanD","Sravanti","Preedhi","Ajitava","Archana"]
}

 variable "ChannelID" {
  type = string
  default = "test qxf2 bot channel ID"
 }

 variable "ETC_CHANNEL" {
  type = string
  default = "etc channel ID"
 }

 variable "Qxf2Bot_USER" {
  type = string
  default = "qxf2Bot user"
 }

variable "URLprefix" {
  type = string
  default = "http://"
}