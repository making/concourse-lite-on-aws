locals {
  vpc_count = "${length(var.existing_vpc_id) > 0 ? 0 : 1}"
  vpc_id    = "${length(var.existing_vpc_id) > 0 ? var.existing_vpc_id : join(" ", aws_vpc.vpc.*.id)}"
}

resource "aws_eip" "concourse_eip" {
  depends_on = ["aws_internet_gateway.ig"]
  vpc        = true
}

resource "tls_private_key" "concourse_vms" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "concourse_vms" {
  key_name   = "${var.env_id}_concourse_vms"
  public_key = "${tls_private_key.concourse_vms.public_key_openssh}"
}