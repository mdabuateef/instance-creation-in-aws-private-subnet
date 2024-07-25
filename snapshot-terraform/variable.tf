variable "aws_region" {
    description = "the aws region"
    type        = string
}
# Specify the volume ID for which to create a snapshot
variable "volume_id" {
  description   = "The ID of the EBS volume to snapshot"
  type          = string
}
variable "availability_zone" {
    description = "the availability zone in which to restore"
    type        = string
}
variable "ami_id" {
    description = "the ami id"
    type        = string
}

variable "instance_type" {
    description = "the instance type"
    type        = string   
}
variable "subnet_id" {
    description = "the subnet id"
    type        = string 
}
variable "key_name" {
    description ="the key name for the ec2"
    type        = string
}
variable "security_group_id" {
    type = list(string)
}
