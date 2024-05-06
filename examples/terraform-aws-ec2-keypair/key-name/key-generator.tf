# To generate secure key pair for ec2 instance
resource "tls_private_key" "newsletter_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "newsletter_generated_key" {
  key_name    = var.key_name
  public_key  = tls_private_key.newsletter_key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.newsletter_key.private_key_pem}' > "${var.temp_path}/${var.key_name}.pem"
      chmod 400 "${var.temp_path}/${var.key_name}.pem"
    EOT
  }
}

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
}