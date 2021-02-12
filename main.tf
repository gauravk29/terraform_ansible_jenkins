# Provider

provider "aws" {
  profile = "default"
  region  = var.aws_region
}
/*
terraform {
  backend "s3" {
    bucket = "terraform-bkt-gk"
    key    = "devops/vpc_demo/terraform.tfstate"
    region = "us-east-1"
  }
}
*/

# Create VPC

# Production

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr1
  instance_tenancy = "default"

  tags = {
    Name = "vpc_production"
  }
}

# Create Subnets

# Production
resource "aws_subnet" "web1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "web-production"
  }
}

# Create & Attach Internet Gateway to the VPC

# Production

resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "IGW_production"
  }
  depends_on = [aws_internet_gateway.gw1]
}

# Create Route Tables & Attach to Corresponding Subnets

# Production

resource "aws_route_table" "r1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw1.id
  }

  tags = {
    Name = "Public Route Table"
  }
  depends_on = [aws_internet_gateway.gw1]
}

# Attach subnet to Route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web1.id
  route_table_id = aws_route_table.r1.id
}

resource "aws_security_group" "all_traffic1" {
  name        = "SG_VPC"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc.main]

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group_rule" "ssh_inbound_access1" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.all_traffic1.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Create EC2 instances in their respective VPCs
/*
resource "aws_instance" "web1" {
  ami                         = "ami-0885b1f6bd170450c"
  instance_type               = "t2.micro"
  key_name                    = "nv_keypair"
  vpc_security_group_ids      = ["${aws_security_group.all_traffic1.id}"]
  associate_public_ip_address = true
  tags = {
    Name = "BP Webserver"
  }
  subnet_id = aws_subnet.web1.id
provisioner "remote-exec" {
    inline = ["sudo apt-get -qq install python -y"]
  }
provisioner "local-exec" {
  command = <<EOT
    sleep 30;
      echo "${aws_instance.web1.public_ip}";
      EOT
  }
}
*/
resource "aws_instance" "web2" {
  ami           = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  key_name        = "nv_keypair"
  vpc_security_group_ids = ["${aws_security_group.all_traffic1.id}"]
  associate_public_ip_address = true

  tags = {
    Name = "Openstack Server"
  }
  subnet_id     = aws_subnet.web1.id

  connection {
    private_key = "${var.private_key}"
    user        = "${var.ansible_user}"
    host        = "${aws_instance.web2.public_ip}"
  }
  
  provisioner "local-exec" {
  command = <<EOT
    sleep 120;
      >openstack.ini;
	  echo "[openstack]" | tee -a openstack.ini;
	  echo "${aws_instance.web2.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a openstack.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i openstack.ini ../playbook/openstack.yml
    
    EOT
  }

}
/*
# These are Elastic IPs & not the Public IPs on the VM's Interfaces
resource "aws_eip" "ip1" {
  vpc      = true
  instance = aws_instance.web1.id
}
resource "aws_eip" "ip2" {
  vpc      = true
  instance = aws_instance.web2.id
}
output "ip1" {
  value = aws_eip.ip1.public_ip
}
output "ip2" {
  value = aws_eip.ip2.public_ip
}
*/
