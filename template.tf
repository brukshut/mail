data "template_file" "user_data" {
  template = "${file("${path.module}/files/user_data.tmpl")}"

  vars {
    hostname     = "${element(split(".", var.private_fqdn), 0)}"
    private_fqdn = "${var.private_fqdn}"
    private_ip   = "${var.private_ip}"
  }
}
