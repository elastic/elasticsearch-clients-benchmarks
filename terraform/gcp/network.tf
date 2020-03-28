resource "google_compute_network" "vpc_network" {
  name                    = "elasticsearch-clients-benchmarks"
  description             = "Network for the clients benchmarks instances"
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
