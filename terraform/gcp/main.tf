provider "google" {
  project = "elastic-clients"
  region  = var.instance_region
  zone    = var.instance_zone
}

resource "random_id" "build_id" {
  byte_length = 8
}
