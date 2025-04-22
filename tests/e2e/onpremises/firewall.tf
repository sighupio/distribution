resource "hcloud_firewall" "haproxy" {
  name = "e2e-firewall-${var.ci_number}"

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "1-65535"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}