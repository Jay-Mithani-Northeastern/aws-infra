
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = length(local.public_cidr_blocks)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.public_cidr_blocks[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(local.private_cidr_blocks)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_cidr_blocks[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public_route_association" {
  count = length(aws_subnet.public_subnet)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_association" {
  count = length(aws_subnet.private_subnet)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_iam_instance_profile" "profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_csye6225_role.name
}
resource "aws_instance" "demo" {
  ami                         = var.ami
  key_name                    = var.key_name
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet[0].id
  security_groups             = ["${aws_security_group.instance.id}"]
  disable_api_termination     = false
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_blook_device_size
    delete_on_termination = true
  }

  tags = {
    "Name" = var.instance_name
  }

  user_data = <<-EOF
   #!/bin/bash
      echo DATABASE_URL=${var.db_dialect}://${var.db_username}:${var.db_password}@${aws_db_instance.postgresql_instance.endpoint}/${var.db_name} >> /etc/environment
      echo S3_BUCKET_NAME=${aws_s3_bucket.private.bucket} >> /etc/environment
      systemctl restart webapp.service
    EOF
}

resource "aws_security_group" "instance" {
  name_prefix = "application-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = local.ingress_port[0]
    to_port     = local.ingress_port[0]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = local.ingress_port[1]
    to_port     = local.ingress_port[1]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = local.ingress_port[2]
    to_port     = local.ingress_port[2]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = local.ingress_port[3]
    to_port     = local.ingress_port[3]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

