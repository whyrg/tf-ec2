provider "aws" {
  version = "~> 2.0"
  region = var.region
  access_key = var.scalr_aws_access_key
  secret_key = var.scalr_aws_secret_key
}


data "aws_availability_zones" "available" {}

data "aws_vpcs" "vpcs" {
  tags = {
    Name = "Terraform-TCG-dev"
  }
}

data "aws_subnet_ids" "subnet" {
  vpc_id = element(tolist(data.aws_vpcs.vpcs.ids), 0)
  filter {
    name = "availability-zone"
    values = [element(random_shuffle.az.result,0)]
  }
}

resource "random_shuffle" "az" {
  input = data.aws_availability_zones.available.names
  result_count = 1
}


data "aws_ami" "aws_linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }
  filter {
    name = "state"
    values = ["available"]
  }
}

resource "aws_instance" "ec2" {
  ami = data.aws_ami.aws_linux.id
  # a hacky way of doing input validation. If not a valid az name, use a random az
  # https://github.com/hashicorp/terraform/issues/2847
  availability_zone = contains(data.aws_availability_zones.available.names, var.availability_zone) ? var.availability_zone : element(random_shuffle.az.result,0)
  instance_type = var.size
  key_name = "team_dev"
  subnet_id = element(tolist(data.aws_subnet_ids.subnet.ids),0)
  tags = {
    Name = var.name
    Owner = "scalr"
  }
#  user_data = file(userdata.txt)
  vpc_security_group_ids = []
  credit_specification {
    cpu_credits = "unlimited"
  }
}

resource "aws_security_group" "allow_ssh" {
  count = var.firewall_campus ? 1 : 0
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
  depends_on = [ "aws_security_group.allow_ssh" ]
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_ssh.id
}


resource "aws_network_interface_sg_attachment" "sg_attachment" {
  depends_on = [ "aws_security_group.allow_ssh" ]
  security_group_id = aws_security_group.allow_ssh.id
  network_interface_id = aws_instance.ec2.primary_network_interface_id
}
