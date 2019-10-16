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

resource "aws_security_group" "allow_web" {
  name = "allow_web_${var.instance-id}"
  description = "Allow http/s traffic from all"
  vpc_id = element(tolist(data.aws_vpcs.vpc.ids),0)
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_web.id
}

resource "aws_security_group_rule" "https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_web.id
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id = aws_security_group.allow_web.id
  network_interface_id = data.aws_instance.instance.network_interface_id
}
