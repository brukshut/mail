variable "access_list" {
  description = "list of ips in CIDR notation"
  type        = "list"
}

variable "ami_id" {}
variable "bucket" {}
variable "domain" {}
variable "instance_type" {}
variable "key_name" {}
variable "mail_eip_id" {}

variable "mail_eip_ip" {
  type = "list"
}

variable "name" {}
variable "private_fqdn" {}
variable "private_ip" {}
variable "eni_subnet_id" {}
variable "private_subnet_id" {}
variable "public_subnet_id" {}
variable "private_zone_id" {}
variable "public_zone_id" {}
variable "public_fqdn" {}
variable "region" {}
variable "user" {}
variable "vpc_cidr" {}
variable "vpc_id" {}
