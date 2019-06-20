resource "aws_security_group" "group" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "${var.name}"

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    create_before_destroy = false
  }

  ingress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}", "${var.access_list}"]
    protocol    = -1
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
