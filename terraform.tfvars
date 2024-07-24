ami_id           = "your-ami-id"
instance_type    = "instance-type"
cidr_block       = "your-cidr-block"
public_subnet    = "public-cidr-block" 
private_subnet   = "private-subnet-block" 
key_name         = "your-key_name"

public_instance_tags = {
    Name        = "public-instance"
    Environment = "bastion"
  }
  private_instance_tags = {
    Name        = "private-instance"
    Environment = "my_ec2"
  }
