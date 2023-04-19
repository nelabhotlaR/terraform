# Terraform Output Values
output "instance_publicip" {
  description = "EC2 Instance Public IP"
  value = {for instance in aws_instance.myec2memegeninstance: instance.id => instance.public_ip}
}

output "instance_publicdns" {
  description = "EC2 Instance Public DNS"
  value = {for instance in aws_instance.myec2memegeninstance: instance.id => instance.public_dns}
}