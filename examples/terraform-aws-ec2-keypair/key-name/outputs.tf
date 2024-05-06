output "keyname" {
    value = aws_key_pair.newsletter_generated_key.key_name
}

output "privatekey" {
    value = tls_private_key.newsletter_key.private_key_pem
}