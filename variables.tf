variable "region" {
  default = "us-east-1"
}
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
data "aws_availability_zones" "available" {
  state = "available"
}
locals {
  azs                 = data.aws_availability_zones.available.names
  public_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_cidr_blocks = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}
