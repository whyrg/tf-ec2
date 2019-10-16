provider "aws" {
  version = "~> 2.0"
  region = "${var.region}"
  access_key = "${var.scalr_aws_access_key}"
  secret_key = "${var.scalr_aws_secret_key}"
}


data "aws_availability_zones" "available" {}

data "aws_vpcs" "vpcs" {
  tags = {
    Name = var.vpc_name
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

