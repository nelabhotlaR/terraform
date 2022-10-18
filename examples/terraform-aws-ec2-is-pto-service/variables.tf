
# region in which the instance going to be deployed.
variable "region" {
    description = "is pto detector service ec2 instance deploy region"
    type = string
    default = "us-east-1"
}

# using map declaring 3 different instance types for dev, test and prod.

variable "ispto_service_ec2_inst_type" {
    description = "deploying ec2 instance type for is-pto-service for dev, test and prod"
    type = map(string)
    default = {
      "dev" = "t3.micro"
      "test"= "t3.small"
      "prod"= "t3.large"
    }
}

# PEM file name to ssh into instance.
variable "is_pto_service_key_pair" {
    description = "defining the PEM key file name to ssh into ec2 instance"
    type = string
    default = "isptoservice"
}


