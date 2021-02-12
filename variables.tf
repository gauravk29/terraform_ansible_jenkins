variable "aws_region" {
  description = "Default AWS Region"
  default     = "us-east-1"
}

variable "vpc_cidr1" {
  description = "VPC CIDR by default"
  default     = "10.20.0.0/16"
}

variable "vpc_cidr2" {
  description = "VPC CIDR by default"
  default     = "11.20.0.0/16"
}

variable "private_key" {
  default = "/home/ubuntu/nv_keypair.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}
