variable "public_subnet_id" {
  description = "The ID of the public subnet"
  type        = string
}
variable "private_subnet_id" {
  description = "The ID of the private subnet"
  type        = string
}
variable "security_group_id" {
  description = "The ID of the security group"
  type        = string
}
variable "ami_id" {
  description = "The ID of the AMI"
  type        = string
}
variable "instance_type" {
    type = string
}
variable "private_instance_tags" {
  description = "Tags for the pub instance"
  type        = map(string)
}
variable "public_instance_tags" {
  description = "Tags for the public EC2 instance"
  type        = map(string)
}
variable "key_name" {
  description = "The name of the key pair"
  type        = string
}