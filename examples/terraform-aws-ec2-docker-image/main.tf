 
# Create an EC2 instance
resource "aws_instance" "docker_instance" {
  ami           = data.aws_ami.ubuntu.id  # AMI ID
  instance_type = var.newsletter_ec2_inst_type
  key_name      = var.is_newsletter_key_pair  #key pair name
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
    tags = {
        "Name"  : "docker-EC2instance"
    }
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
   provisioner "file" {
    source      = "nginx_config.template"
    destination = "/home/ubuntu/default"
    connection {
      host        = aws_instance.docker_instance.public_ip
      user        = "ubuntu"
      private_key = file("/home/nelbo/code/qxf2/terraform/examples/terraform-aws-ec2-docker-image/isptoservice.pem")
    }
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Add Docker GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update -y
    
    # Install Docker
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
   
    sudo mkfs -t ext4 /dev/nvme1n1
    sudo mkdir /data
    sudo mount /dev/nvme1n1 /data
    
    # Configure Docker to use the mounted NVMe device
    sudo mkdir -p /data/new-docker-root-dir
    echo '{
      "data-root": "/data/new-docker-root-dir"
    }' | sudo tee /etc/docker/daemon.json > /dev/null
    sudo systemctl restart docker

    # Download Docker image
    sudo docker pull qxf2rohand/newsletter_automation:latest  # Replace with your Docker image name
    echo "sleeping time to give time to download docker before docker start"
    sleep 2m
    # Run Docker container
    sudo docker run -it -p 5000:5000 qxf2rohand/newsletter_automation  # run Docker image
   
  EOF
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.docker_instance.public_ip
      user        = "ubuntu"
      private_key = file("/home/nelbo/code/qxf2/terraform/examples/terraform-aws-ec2-docker-image/isptoservice.pem")
    }
    inline = [ 
     # nginx installation
      "sudo apt install nginx -y",
      "cd /home/ubuntu",
      "echo going to copy file",
      "sudo cp /home/ubuntu/default /etc/nginx/sites-available/",
      "sudo nginx -t",
      "sudo systemctl restart nginx"
    ]
  }
}

# Create an EBS volume
resource "aws_ebs_volume" "extra_volume" {
  availability_zone = aws_instance.docker_instance.availability_zone # availability zone
  size              = 20          # volume size (in GB)
  tags = {
    Name = "newsletter"
  }
}

# Attach the EBS volume to the EC2 instance
resource "aws_volume_attachment" "attachment" {
  device_name = "/dev/sdf"             # device name
  volume_id   = aws_ebs_volume.extra_volume.id
  instance_id = aws_instance.docker_instance.id
  force_detach = true
}


# https://www.baeldung.com/linux/docker-fix-no-space-error
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/step4-extend-file-system.html
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/nvme-ebs-volumes.html
