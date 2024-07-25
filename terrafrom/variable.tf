# variables.tf (Root Module)
variable "ami_id" {
  description = "The ID of the AMI"
  type        = string
}
variable "instance_type" {
  description = "The type of the instance"
  type        = string
}
variable "key_name" {
  description = "The name of the key pair"
  type        = string
}
variable "private_instance_tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}
variable "public_instance_tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  
}
variable "public_subnet" {
    description = "public subnet cidr"
    type        = string
}
variable "private_subnet" {
    description = "public subnet cidr"
    type        = string
}
variable "cidr_block" {
    description = "cidr number"
    type        = string
}
