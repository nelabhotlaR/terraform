
# Create an EC2 instance with volume size 30gb. 

resource "aws_instance" "docker_instance" {
  ami                    = data.aws_ami.ubuntu.id # AMI ID
  instance_type          = var.newsletter_ec2_inst_type
  key_name               = var.is_newsletter_key_pair #key pair name
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
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
      host        = aws_instance.docker_instance.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
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
      "sudo usermod -aG docker ubuntu"
    ]
  }
  # to pull the docker image and run the docker image
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.docker_instance.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }
    inline = [
      # Download Docker image
      "sudo docker pull qxf2rohand/newsletter_automation:latest",
      # Run Docker container
      "sudo docker run -it -d -p 5000:5000 qxf2rohand/newsletter_automation"
    ]
  }
  # to serve newsletter app nginx download and configuration
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
      "sudo systemctl restart nginx",
    ]
  }
}
# lambda repo clone. 
resource "null_resource" "aws_lambda_repo_clone" {
  provisioner "local-exec" {
    command     = <<-EOT
    git clone ${var.github_repo}
    pip3 install -r /tmp/qxf2-lambdas/${var.github_repo_name}/requirements.txt -t /tmp/qxf2-lambdas/${var.github_repo_name}/
  EOT
    interpreter = ["/bin/bash", "-c"]
    working_dir = "/tmp/"
    environment = {
      GIT_SSH_COMMAND = "ssh -o StrictHostKeyChecking=no"
    }
  }
}
/*
resource "null_resource" "install_dependencies" {
  depends_on = [null_resource.aws_lambda_repo_clone]
  count = var.clone_repository ? 1 : 0
  triggers = {
    dependencies_versions = filemd5("/tmp/qxf2-lambdas/${var.github_repo_name}/requirements.txt")
    source_versions       = filemd5("/tmp/qxf2-lambdas/${var.github_repo_name}/url_filtering_lambda_rohini.py")
    clone_triggers        = null_resource.aws_lambda_repo_clone.id
  }
}
*/
# archiving the lambda using archive_file
data "archive_file" "zip" {
  depends_on  = [null_resource.aws_lambda_repo_clone]
  type        = "zip"
  source_dir  = "/tmp/qxf2-lambdas/${var.github_repo_name}"
  output_path = "/tmp/lambda_code.zip"
}
# lambda layer version attaching to lambda function
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = data.archive_file.zip.output_path
  layer_name = var.lambda_layer_name
}

# Lambda creation with environment variables
resource "aws_lambda_function" "newsletter_lambda" {
  depends_on    = [data.archive_file.zip]
  function_name = var.lambda_function_name
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = 60
  memory_size   = 128
  dead_letter_config { # DLQ offers the possibility to investigate errors or failed requests to the connected Lambda function
    target_arn = aws_sqs_queue.newsletter_sqs.arn
  }
  reserved_concurrent_executions = 100 # Adding concurrency limits can prevent a rapid spike in usage and costs
  filename                       = "/tmp/lambda_code.zip"
  role                           = aws_iam_role.lambda_role.arn
  layers                         = [aws_lambda_layer_version.lambda_layer.arn]
  environment {
    variables = {
      CHATGPT_API_KEY        = "${var.CHATGPT_API_KEY}"
      CHATGPT_VERSION        = "${var.CHATGPT_VERSION}"
      API_KEY_VALUE          = "${var.API_KEY_VALUE}"
      employee_list          = join(",", "${var.employee_list}")
      channel_ID             = "${var.ChannelID}"
      ETC_CHANNEL            = "${var.ETC_CHANNEL}"
      Qxf2Bot_USER           = "${var.Qxf2Bot_USER}"
      SKYPE_SENDER_QUEUE_URL = aws_sqs_queue.newsletter_sqs.url
      URL                    = format("%s%s", var.URLprefix, aws_instance.docker_instance.public_ip)
      DEFAULT_CATEGORY       = 5
    }
  }
}
# lambda role creation
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

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

//resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
//role       = aws_iam_role.lambda_role.name
//policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
//}

# SQS creation
resource "aws_sqs_queue" "newsletter_sqs" {
  name                       = "newsletter_sqs"
  delay_seconds              = 90
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 60
}
# sqs policy
resource "aws_sqs_queue_policy" "default_policy" {
  queue_url = aws_sqs_queue.newsletter_sqs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "DefaultPolicy",
    Statement = [
      {
        Sid    = "AllowLambdaToSendMessages"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.newsletter_sqs.arn
      },
      {
        Sid    = "AllowLambdaToReceiveMessages"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action   = "sqs:ReceiveMessage"
        Resource = aws_sqs_queue.newsletter_sqs.arn
      },
      {
        Sid    = "AllowLambdaToDeleteMessages"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action   = "sqs:DeleteMessage"
        Resource = aws_sqs_queue.newsletter_sqs.arn
      },
      {
        Sid    = "AllowLambdaToGetQueueAttributes"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action   = "sqs:GetQueueAttributes"
        Resource = aws_sqs_queue.newsletter_sqs.arn
      }
    ]
  })
}
# attaching sqs policy to lambda
resource "aws_iam_policy" "lambda_permissions_policy" {
  name        = "lambda-permissions-policy"
  description = "Permissions policy for Lambda to access SQS queue"

  policy = jsonencode({
    Version = "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ListQueues",
          "sqs:ChangeMessageVisibility",
          "sqs:SendMessageBatch",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:ListQueueTags",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:DeleteMessageBatch",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:SetQueueAttributes"
        ],
        "Effect" : "Allow",
        "Resource" : [
          aws_sqs_queue.newsletter_sqs.arn
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_permissions_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# https://www.baeldung.com/linux/docker-fix-no-space-error
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/step4-extend-file-system.html
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/nvme-ebs-volumes.html

