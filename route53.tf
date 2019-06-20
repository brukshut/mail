resource "aws_route53_record" "private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.private_fqdn}"
  type    = "A"
  ttl     = "300"
  records = ["${var.private_ip}"]
}
