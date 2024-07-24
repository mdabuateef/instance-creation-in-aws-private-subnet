# resource "aws_instance" "web" {
#   ami                         = var.ami_id
#   instance_type               = var.instance_type
#   subnet_id                   = var.public_subnet_id
#   vpc_security_group_ids      = [var.security_group_id]
#   associate_public_ip_address = true
#   key_name                    = var.key_name

#   tags = var.tags
# }

# output "instance_id" {
#   value = aws_instance.web.id
# }

# EC2 instance in a public subnet
resource "aws_instance" "web_public" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = var.public_instance_tags
}

# EC2 instance in a private subnet
resource "aws_instance" "web_private" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = false
  key_name                    = var.key_name

  tags = var.private_instance_tags
}

# Output for the EC2 instance IDs
output "instance_id_public" {
  value = aws_instance.web_public.id
}

output "instance_id_private" {
  value = aws_instance.web_private.id
}