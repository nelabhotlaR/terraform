
# region in which the instance going to be deployed.
variable "region" {
    description = "meme-generator ec2 instance deploy region"
    type = string
    default = "us-east-1"
}

# using map declaring 3 different instance types for dev, test and prod.

variable "meme_generator_ec2_inst_type" {
    description = "declaring ec2 instance type for meme-generator for dev, test and prod"
    type = map(string)
    default = {
      "dev" = "t3.micro"
      "test"= "t3.small"
      "prod"= "t3.large"
    }
}

# PEM file name to ssh into instance.
variable "meme_generator_key_pair" {
    description = "defining the PEM key file name to ssh into ec2 instance"
    type = string
    default = "meme-generator"
}

variable "host"{
}

variable "password" {
    type = string
}



