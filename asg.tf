resource "aws_launch_configuration" "configuration" {
  name_prefix          = "${var.name}"
  image_id             = "${var.ami_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}"
  iam_instance_profile = "${module.mail_profile.name}"
  security_groups      = ["${aws_security_group.group.id}"]
  user_data_base64     = "${base64encode(data.template_file.user_data.rendered)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "mail" {
  name                      = "${var.name}"
  launch_configuration      = "${aws_launch_configuration.configuration.id}"
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 15
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["${var.private_subnet_id}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.name}"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}
