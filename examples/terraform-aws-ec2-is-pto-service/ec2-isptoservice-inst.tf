resource "aws_instance" "myec2instace" {
    ami = data.aws_ami.ubuntu.id
    #instance_type = var.instance_type_list[1]
    instance_type = var.ispto_service_ec2_inst_type["test"]
    #user_data = file("${path.module}/ptoinstall.sh")
    key_name = var.is_pto_service_key_pair
    vpc_security_group_ids = [aws_security_group.pto-ssh.id]
    count = 1
    tags = {
        "Name"  : "PTO-EC2ins-${count.index}"
    }
}

resource "local_file" "ip" {
    filename = "host"
    content = <<-EOT
        %{for ip in aws_instance.myec2instace.*.public_ip ~}
        ${ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/nelbo/Downloads/isptoservice.pem ansible_connection=ssh ansible_port=22
        %{endfor ~}
    EOT
}
