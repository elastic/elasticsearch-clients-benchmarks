provider "google" {
  project = "elastic-clients"
  region  = var.instance_region
  zone    = var.instance_zone
}

resource "random_id" "build" {
  byte_length = 8
}

resource "random_id" "server_instance" {
  count       = var.node_count
  byte_length = 8
}
