variable "region" {
  type = string
}

variable "profile" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "public_subnet_cidr" {
  type = list(string)
}

variable "private_subnet_cidr" {
  type = list(string)
}

variable "application_security_group_ingress" {
  type = list(number)
}
locals {
  azs                 = data.aws_availability_zones.available.names
  public_cidr_blocks  = var.public_subnet_cidr
  private_cidr_blocks = var.private_subnet_cidr
  ingress_port        = var.application_security_group_ingress
}

variable "db_identifier" {
  type = string
}
variable "db_engine" {
  type = string
}
variable "db_engine_version" {
  type = string
}
variable "db_instance_class" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

variable "db_pg_name" {
  type = string
}
variable "db_pg_family" {
  type = string
}
variable "db_pg_description" {
  type = string
}

variable "db_dialect" {
  type = string
}

variable "s3_acl" {
  type = string
}

variable "s3_lifecycle_rule_id" {
  type = string
}
variable "s3_lifecyle_enabled" {
  type = bool
}

variable "s3_lifecycle_rule_duration" {
  type = number
}

variable "s3_lifecycle_rule_storage_class" {
  type = string
}

variable "ami" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "root_blook_device_size" {
  type =number
}

variable "domain_name" {
  type = string
}
data "aws_iam_policy" "cloud_watch_access" {
  name = "CloudWatchAgentServerPolicy"
}