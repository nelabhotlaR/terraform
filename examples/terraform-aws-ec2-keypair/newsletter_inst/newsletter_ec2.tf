module "key" {
  source = "../key-name"
} 


# Create an EC2 instance with volume size 30gb. 
resource "aws_instance" "newsletter_instance" {
  ami                    = data.aws_ami.ubuntu.id # AMI ID
  instance_type          = var.newsletter_ec2_inst_type
  key_name               = module.key.keyname
  vpc_security_group_ids = [local.security_groups.sg_ping]
  ebs_optimized          = true # Ensuring that EC2 instances are EBS-optimized will help to deliver enhanced performance for EBS workloads
  monitoring             = true # Insights about the performance and utilization of your instances
  tags = {
    "Name" : "Newsletter_automation"
  }
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
    encrypted   = true
  }
  # to install/start/enable docker
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.newsletter_instance.public_ip
      user        = "${var.remoteuser}"
      private_key = file("${var.temp_path}/${var.key_name}.pem")
    }
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ${var.remoteuser}"
    ]
  }
  # to prepare the docker image from newsletter_automation clone and run the docker image
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.newsletter_instance.public_ip
      user        = "${var.remoteuser}"
      private_key = file("${var.temp_path}/${var.key_name}.pem")
    }
    inline = [
      # clone the repo
      "cd ${var.temp_path}",
      "git clone https://github.com/qxf2/newsletter_automation.git",
      "cd newsletter_automation",
      "docker build --tag newsletter_automation .",
      "sudo docker run -it -d -p 5000:5000 newsletter_automation"
    ]
  }
  # to serve newsletter app nginx download and configuration
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.newsletter_instance.public_ip
      user        = "${var.remoteuser}"
      private_key = file("${var.temp_path}/${var.key_name}.pem")
    }
    inline = [
      # nginx installation
      "sudo apt install nginx -y",
      "sudo apt-get install -y git",
      "cd ${var.homedir}",
      "echo going to copy file",
      "git clone https://github.com/nelabhotlaR/nginx-config-file.git",
      "sudo mv ~/nginx-config-file/nginx_config.template /etc/nginx/sites-available/default",
      "sudo nginx -t",
      "sudo systemctl restart nginx",
    ]
  }
}
/*
# deleting the private key when terminating the instance.
resource "null_resource" "delete_key" {
  triggers = {
    key_path = "${var.temp_path}/${var.key_name}.pem"
    }
provisioner "local-exec" {
  when = destroy
  command = "rm -f ${self.triggers.key_path}"
  on_failure = continue // This allows the destroy provisioner to not fail even if the file doesn't exist.
}
depends_on = [ aws_key_pair.newsletter_generated_key ]
}
# deleting the folder when terminating the instance.
resource "null_resource" "delete_folder" {
  triggers = {
    key_path = "${var.temp_path}/${var.foldername}"
  }
provisioner "local-exec" {
  when = destroy
  command = "rm -f -r ${self.triggers.key_path}"
  on_failure = continue
}
}
# deleting the zip file when terminating the instance.
resource "null_resource" "delete_zipfile" {
  triggers = {
    key_path = "${var.temp_path}/${var.zipfilename}"
  }
provisioner "local-exec" {
  when = destroy
  command = "rm -f ${self.triggers.key_path}"
  on_failure = continue
}
}*/

# https://stackoverflow.com/questions/54303821/how-to-reference-a-resource-created-in-one-file-in-another-file-in-terraform