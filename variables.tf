variable "size" {
  type = string
  default = "t3a.micro"
}

variable "name" {
  type = string
}

variable "availability_zone" {
  type = string
  default = "random"
}

variable "region" {
  type = string
}

variable "firewall_campus" {
  type = bool
  default = true
}

variable "firewall_http_s" {
  type = bool
  default = true
}

variable "firewall_custom" {
  type = string
}


variable "scalr_aws_secret_key" {}
variable "scalr_aws_access_key" {}

