output "instance_id_publics" {
  value = aws_instance.web_public.id
}

output "instance_id_privates" {
  value = aws_instance.web_private.id
}
output "public_instance_publics_ip" {
  value = aws_instance.web_public.public_ip
}

output "public_instance_privates_ip" {
  value = aws_instance.web_public.private_ip
}

output "private_instance_privates_ip" {
  value = aws_instance.web_private.private_ip
}