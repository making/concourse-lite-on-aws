resource "aws_vpc" "vpc" {
  count                = "${local.vpc_count}"
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags {
    Name = "${var.env_id}-vpc"
  }
}

resource "aws_subnet" "concourse_subnet" {
  vpc_id     = "${local.vpc_id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 8, 0)}"
  availability_zone = "${var.availability_zones[0]}"

  tags {
    Name = "${var.env_id}-concourse-subnet"
  }
}

resource "aws_route_table" "concourse_route_table" {
  vpc_id = "${local.vpc_id}"
}

resource "aws_route" "concourse_route_table" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
  route_table_id         = "${aws_route_table.concourse_route_table.id}"
}

resource "aws_route_table_association" "route_concourse_subnets" {
  subnet_id      = "${aws_subnet.concourse_subnet.id}"
  route_table_id = "${aws_route_table.concourse_route_table.id}"
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${local.vpc_id}"
}

locals {
  concourse_name        = "concourse-${var.env_id}"
  internal_cidr        = "${aws_subnet.concourse_subnet.cidr_block}"
  internal_gw          = "${cidrhost(local.internal_cidr, 1)}"
  concourse_internal_ip = "${cidrhost(local.internal_cidr, 6)}"
}
