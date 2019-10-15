variable "size" {
  type = "string"
  default = "t3a.micro"
}

variable "name" {
  type = "string"
}

variable "availability_zone" {
  type = "string"
  default = "random"
}

variable "region" {
  type = "string"
}

variable "vpc_name" {
  type = "string"
}

variable "scalr_aws_secret_key" {}
variable "scalr_aws_access_key" {}

