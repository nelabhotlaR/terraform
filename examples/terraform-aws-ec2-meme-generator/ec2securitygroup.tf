/* adding security group for meme-generator instance for only ssh. 
    Post ec2 deployement ssh to instance and deploy required web app and web servers */

#ispto-ssh traffic

resource "aws_security_group" "memegen-ssh" {
  name        = "meme-ssh"
  description = "ssh port to ssh into instance"
  ingress {
    description      = "Allow port 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  // To All port 80 transport
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all ips and ports outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0" ]
  }

  tags = {
    Name = "meme-generator-ssh"
  }
}

