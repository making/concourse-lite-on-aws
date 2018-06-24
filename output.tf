output "default_key_name" {
  value = "${aws_key_pair.concourse_vms.key_name}"
}

output "private_key" {
  value     = "${tls_private_key.concourse_vms.private_key_pem}"
  sensitive = true
}

output "external_ip" {
  value = "${aws_eip.concourse_eip.public_ip}"
}

output "concourse_address" {
  value = "https://${aws_eip.concourse_eip.public_ip}"
}

output "concourse_security_group" {
  value = "${aws_security_group.concourse_security_group.id}"
}

output "concourse_default_security_groups" {
  value = ["${aws_security_group.concourse_security_group.id}"]
}

output "subnet_id" {
  value = "${aws_subnet.concourse_subnet.id}"
}

output "az" {
  value = "${aws_subnet.concourse_subnet.availability_zone}"
}

output "vpc_id" {
  value = "${local.vpc_id}"
}

output "region" {
  value = "${var.region}"
}

output "concourse_name" {
  value = "${local.concourse_name}"
}

output "internal_cidr" {
  value = "${local.internal_cidr}"
}

output "internal_gw" {
  value = "${local.internal_gw}"
}

output "concourse_internal_ip" {
  value = "${local.concourse_internal_ip}"
}

output "concourse_iam_user_name" {
  value = "${aws_iam_user.concourse.name}"
}

output "concourse_iam_user_access_key" {
  value = "${aws_iam_access_key.concourse.id}"
}

output "concourse_iam_user_secret_key" {
  value = "${aws_iam_access_key.concourse.secret}"
}
