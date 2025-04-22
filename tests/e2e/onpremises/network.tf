resource "hcloud_network" "network" {
  name     = "e2e-${var.ci_number}"
  ip_range = "10.10.0.0/16"
}

resource "hcloud_network_subnet" "network_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.10.1.0/24"
}
