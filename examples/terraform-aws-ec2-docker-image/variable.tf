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

