resource "hcloud_ssh_key" "ssh_key" {
  name       = "E2E SSH Key ${var.ci_number}"
  public_key = var.public_key
}