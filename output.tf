output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}
output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "security_group_id" {
  value = module.security-grp.security_group_id
}

output "ec2_instance_id_public" {
  value = module.ec2.instance_id_public
}

output "ec2_instance_id_private" {
  value = module.ec2.instance_id_private
}
