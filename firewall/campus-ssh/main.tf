provider "aws" {
  version = "~> 2.0"
  region = "${var.region}"
  access_key = "${var.scalr_aws_access_key}"
  secret_key = "${var.scalr_aws_secret_key}"
}
data "aws_instance" "instance" {

  instance_id = var.instance-id
}

data "aws_vpcs" "vpc" {
  tags = {
    Name = "Terraform-TCG-dev"
  }
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh_${var.instance-id}"
  description = "Allow ssh from campus"
  vpc_id = element(tolist(data.aws_vpcs.vpc.ids),0)
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["171.64.0.0/14"]
  security_group_id = aws_security_group.allow_ssh.id
}


resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id = aws_security_group.allow_ssh.id
  network_interface_id = data.aws_instance.instance.network_interface_id
}
