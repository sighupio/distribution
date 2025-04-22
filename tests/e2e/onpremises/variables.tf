variable "hcloud_token" {
  type = string
  sensitive = true
}

variable "public_key" {
  type = string
  sensitive = true
}

variable "private_key"{
  type = string
  sensitive = true
}

variable "ci_number" {
  type = string
}