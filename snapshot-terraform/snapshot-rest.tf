provider "aws" {
  region = var.aws_region
}

# Create a snapshot of the specified volume
resource "aws_ebs_snapshot" "example" {
  volume_id = var.volume_id
  tags = {
    Name = "ExampleSnapshot"
  }
}

# Data source to find the most recent snapshot for the specified volume
data "aws_ebs_snapshot" "latest" {
  most_recent = true
  filter {
    name   = "volume-id"
    values = [var.volume_id]
  }
  depends_on = [aws_ebs_snapshot.example]
}

# Create a new EBS volume from the latest snapshot
resource "aws_ebs_volume" "restored_volume" {
  availability_zone = var.availability_zone
  snapshot_id       = data.aws_ebs_snapshot.latest.id

  tags = {
    Name = "RestoredVolume"
  }
}

# Provision a new EC2 instance
resource "aws_instance" "private_instance" {
  ami           = var.ami_id  
  instance_type = var.instance_type
  subnet_id     = var.subnet_id  
  key_name      = var.key_name  
  associate_public_ip_address = false

  tags = {
    Name = "PrivateInstance"
  }
}

# Attach the new volume to the new instance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.restored_volume.id
  instance_id = aws_instance.private_instance.id
}
