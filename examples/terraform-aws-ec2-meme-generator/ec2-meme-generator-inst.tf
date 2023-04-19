resource "aws_instance" "myec2memegeninstance" {
    ami = data.aws_ami.ubuntu.id
    #instance_type = var.instance_type_list[1]
    instance_type = var.meme_generator_ec2_inst_type["test"]
    key_name = var.meme_generator_key_pair
    vpc_security_group_ids = [aws_security_group.memegen-ssh.id]
    count = 1
    tags = {
        "Name"  : "memegen-EC2ins-${count.index}"
    }
}
# preparation of host file
resource "local_file" "ip" {
    filename = "meme-gen.txt"
    content = <<-EOT
        %{for ip in aws_instance.myec2memegeninstance.*.public_ip ~}
        ${ip}
        %{endfor ~}
    EOT
}

#connecting to the Ansible control node using SSH connection
resource "null_resource" "nullremote1" {
depends_on = [aws_instance.myec2memegeninstance] 
connection {
 type     = "ssh"
 user     = "ubuntu"
 password = "${var.password}"
     host= "${var.host}" 
}

#copying the meme-gen file to the Ansible control node from local system 
provisioner "file" {
    source      = "meme-gen.txt"
    destination = "/home/ubuntu/meme-generator/ip.txt"
       }
}