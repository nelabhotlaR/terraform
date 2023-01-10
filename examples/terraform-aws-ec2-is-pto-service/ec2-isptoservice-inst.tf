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
# preparation of host file
resource "local_file" "ip" {
    filename = "host"
    content = <<-EOT
        %{for ip in aws_instance.myec2instace.*.public_ip ~}
        ${ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/nelbo/Downloads/isptoservice.pem ansible_connection=ssh ansible_port=22
        %{endfor ~}
    EOT
}


resource "null_resource" "localinventory01" {
    triggers = {
        mytest = timestamp()
    }
    provisioner "local-exec" {
        command = <<EOF
            echo "[aws]" > /home/nelbo/code/qxf2/terraform/pto-ansible/hosts
            echo "${aws_instance.myec2instace[0].public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/nelbo/Downloads/isptoservice.pem ansible_connection=ssh ansible_port=22" >> /home/nelbo/code/qxf2/terraform/pto-ansible/hosts
      EOF
    }
}
# https://www.linkedin.com/pulse/integration-terraform-ansible-create-your-own-dynamic-abhinav-paul/

resource "null_resource" "localinventory02" {
    triggers = {
      "mytest" = timestamp()
    }
    provisioner "local-exec" {
        command = <<EOF
            echo "server {" > /home/nelbo/code/qxf2/terraform/pto-ansible/roles/pto/templates/nginx.j2
            echo "listen 80;" >> /home/nelbo/code/qxf2/terraform/pto-ansible/roles/pto/templates/nginx.j2
            echo "server_name ${aws_instance.myec2instace[0].public_ip};" >> /home/nelbo/code/qxf2/terraform/pto-ansible/roles/pto/templates/nginx.j2
            echo "" >> /home/nelbo/code/qxf2/terraform/pto-ansible/roles/pto/templates/nginx.j2
            echo "location / {" >> /home/nelbo/code/qxf2/terraform/pto-ansible/roles/pto/templates/nginx.j2
            echo "include uwsgi_params;" >> /home/nelbo/code/qxf2/terraform/pto-ansible/roles/pto/templates/nginx.j2
            echo "uwsgi_pass unix:/home/ubuntu/practice-testing-ai-ml/aiml.sock;" >> /home/nelbo/code/qxf2/terraform/pto-ansible/roles/pto/templates/nginx.j2
            echo "}}" >> /home/nelbo/code/qxf2/terraform/pto-ansible/roles/pto/templates/nginx.j2
    EOF  
    }
  
}
