provider "google" {
  project = "elastic-clients"
  region  = var.instance_region
  zone    = var.instance_zone
}

resource "random_id" "build_id" {
  byte_length = 8
}

resource "random_id" "server_id" {
  count       = var.server_count
  byte_length = 8
}
