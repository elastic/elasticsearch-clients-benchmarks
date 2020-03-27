provider "google" {
  project = "elastic-clients"
  region  = var.instance_region
  zone    = var.instance_zone
}

resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "vm" {
  name         = "karmi-terraform-test-instance-${random_id.instance_id.hex}"
  machine_type = var.instance_type
  description  = "Testing terraform for clients benchmarks"

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }

  tags = ["allow-ssh", "allow-http"]

  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq nginx"
}

resource "google_compute_network" "vpc_network" {
  name                    = "karmi-terraform-test-network"
  description             = "VPC network for the clients benchmarks instances"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]
}
