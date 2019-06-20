resource "aws_network_interface" "interface" {
  subnet_id       = "${var.eni_subnet_id}"
  private_ips     = ["${var.private_ip}"]
  security_groups = ["${aws_security_group.group.id}"]

  tags {
    Name = "${var.name}"
    FQDN = "${var.private_fqdn}"
  }
}
