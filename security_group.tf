resource "aws_security_group" "concourse_security_group" {
  name        = "${var.env_id}-concourse-security-group"
  description = "concourse"
  vpc_id      = "${local.vpc_id}"

  tags {
    Name = "${var.env_id}-concourse-security-group"
  }

  lifecycle {
    ignore_changes = ["name", "description"]
  }
}

resource "aws_security_group_rule" "concourse_security_group_rule_tcp_ssh" {
  security_group_id = "${aws_security_group.concourse_security_group.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "concourse_security_group_rule_tcp_http" {
  security_group_id = "${aws_security_group.concourse_security_group.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "concourse_security_group_rule_tcp_https" {
  security_group_id = "${aws_security_group.concourse_security_group.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "concourse_security_group_rule_tcp_http8080" {
  security_group_id = "${aws_security_group.concourse_security_group.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "concourse_security_group_rule_tcp_http4443" {
  security_group_id = "${aws_security_group.concourse_security_group.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 4443
  to_port           = 4443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "concourse_security_group_rule_tcp_prometheus" {
  security_group_id = "${aws_security_group.concourse_security_group.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 9391
  to_port           = 9391
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "concourse_security_group_rule_tcp_mbus" {
  security_group_id = "${aws_security_group.concourse_security_group.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 6868
  to_port           = 6868
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "concourse_security_group_rule_allow_internet" {
  security_group_id = "${aws_security_group.concourse_security_group.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}