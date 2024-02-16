variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "profile" {
  default = "personal"
  type    = string
}

variable "aws_az" {
  description = "The Availability Zone to use"
  type        = string
}

# variable "ami_id" {
#   description = "The AMI to be used for the EC2 instance"
#   type        = string
# }

# variable "ssh_cidr_block" {
#   description = "The CIDR block that is allowed SSH access to the instance"
#   type        = string
# }

variable "key_name" {
  description = "The EC2 Key Pair name"
  default = "carsapi_terraform"
  type        = string
}

# to declare private key path
variable "private_key_path" {
  type        = string
  description = "Path to the PEM private key file"
}