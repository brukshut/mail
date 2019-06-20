resource "aws_lb" "lb" {
  name                       = "${var.name}"
  internal                   = false
  load_balancer_type         = "network"
  enable_deletion_protection = false

  tags {
    Name = "${var.public_fqdn}"
  }

  subnet_mapping {
    subnet_id     = "${var.public_subnet_id}"
    allocation_id = "${var.mail_eip_id}"
  }
}

resource "aws_lb_target_group" "smtp" {
  name        = "smtp"
  port        = "25"
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  tags {
    Name = "smtp"
  }
}

resource "aws_lb_target_group" "smtps" {
  name        = "smtps"
  port        = "587"
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  tags {
    Name = "smtps"
  }
}

resource "aws_lb_target_group" "imaps" {
  name        = "imaps"
  port        = "993"
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  tags {
    Name = "imaps"
  }
}

resource "aws_lb_listener" "smtp" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "25"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.smtp.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "smtps" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "587"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.smtps.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "imaps" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "993"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.imaps.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "smtp" {
  target_group_arn = "${aws_lb_target_group.smtp.arn}"
  target_id        = "${var.private_ip}"
  port             = 25
}

resource "aws_alb_target_group_attachment" "smtps" {
  target_group_arn = "${aws_lb_target_group.smtps.arn}"
  target_id        = "${var.private_ip}"
  port             = 587
}

resource "aws_alb_target_group_attachment" "imaps" {
  target_group_arn = "${aws_lb_target_group.imaps.arn}"
  target_id        = "${var.private_ip}"
  port             = 993
}
