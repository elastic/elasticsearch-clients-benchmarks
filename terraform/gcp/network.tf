resource "google_compute_network" "default" {
  name                    = "bench-network-${random_id.build_id.hex}"
  description             = "Network for the clients benchmarks instances"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name          = "bench-subnetwork-${random_id.build_id.hex}"
  ip_cidr_range = "10.0.0.0/22"
  region        = var.instance_region
  network       = google_compute_network.default.self_link
}


resource "google_compute_address" "master" {
  name         = "bench-master-${random_id.build_id.hex}"
  description  = "Elasticsearch cluster master IP"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.default.self_link
}

resource "google_compute_firewall" "allow-internal" {
  name        = "bench-allow-internal"
  description = "Allow internal traffic"
  network     = google_compute_network.default.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/22"]
}

resource "google_compute_firewall" "allow-ssh" {
  name        = "bench-allow-ssh"
  description = "Allow SSH from external"
  network     = google_compute_network.default.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}
