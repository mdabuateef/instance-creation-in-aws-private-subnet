provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source              = "./modules/vpc"
  cidr_block          = var.cidr_block
  public_subnet       = var.public_subnet 
  private_subnet      = var.private_subnet
}

module "security-grp" {
  source              = "./modules/security-grp"
  vpc_id              = module.vpc.vpc_id
}

module "ec2" {
  source              = "./modules/ec2"
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  security_group_id   = module.security-grp.security_group_id
  public_subnet_id    = module.vpc.public_subnet_id
  private_subnet_id   = module.vpc.private_subnet_id
  key_name            = var.key_name
  public_instance_tags = var.public_instance_tags
  private_instance_tags = var.private_instance_tags
}

output "vpc_outputs" {
  value = {
    vpc_id              = module.vpc.vpc_id
    public_subnet_id    = module.vpc.public_subnet_id
    internet_gateway_id = module.vpc.internet_gateway_id
    private_subnet_id   = module.vpc.private_subnet_id
  }
}

output "security_group_output" {
  value = {
    security_group_id = module.security-grp.security_group_id
  }
}
output "public_instance_public_ip" {
  value = module.ec2.public_instance_publics_ip
}
output "private_instance_privates_ip" {
  value = module.ec2.private_instance_privates_ip
}
# output "ec2_instance_id_public" {
#   value = module.ec2.instance_id_public
# }

# output "ec2_instance_id_private" {
#   value = module.ec2.instance_id_private
# }