 
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
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.docker_instance.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }
    inline = [ 
     # nginx installation
      "sudo apt install nginx -y",
      "sudo apt-get install -y git",
      "cd /home/ubuntu",
      "echo going to copy file",
      "git clone https://github.com/nelabhotlaR/nginx-config-file.git",
      "sudo mv ~/nginx-config-file/nginx_config.template /etc/nginx/sites-available/default",
      "sudo nginx -t",
      "sudo systemctl restart nginx"
    ]
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
    # Run Docker container
    sudo docker run -it -p 5000:5000 qxf2rohand/newsletter_automation  # run Docker images
  EOF
}

# Create an EBS volume
resource "aws_ebs_volume" "extra_volume" {
  availability_zone = aws_instance.docker_instance.availability_zone # availability zone
  size              = 30        # volume size (in GB)
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

# lambda function deployment

data "archive_file" "zip" {
  type = "zip"
  source_dir = "${local.function_source_dir}"
  output_path = "outputs/lambda_file.zip"
}

data "archive_file" "lambda_layer_zip" {
  type = "zip"
  source_dir = "${local.requirements_directory}"
  output_path = "outputs/requirements.zip"  
}

resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename = "${data.archive_file.lambda_layer_zip.output_path}"
  layer_name = "${var.lambda_layer_name}"
  
}

resource "aws_lambda_function" "newsletter_lambda" {
  filename         = "${data.archive_file.zip.output_path}"
  #source_code_hash = "${data.archive_file.zip.output_base64sha256}"
  function_name    = "${var.function_name}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "${var.function_handler}"
  runtime          = "python3.9"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  tracing_config {
    mode = "Active"
  }
  
}

# https://www.baeldung.com/linux/docker-fix-no-space-error
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/step4-extend-file-system.html
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/nvme-ebs-volumes.html
