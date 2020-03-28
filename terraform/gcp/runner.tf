resource "google_compute_instance" "runner" {
  name         = "bench-runner-${random_id.build.hex}-${random_id.runner.hex}"
  description  = "bench-runner-${local.client_id}"
  machine_type = var.instance_type_server

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network    = google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.default.self_link
    access_config {}
  }

  tags = ["allow-ssh"]

  labels = {
    group     = "bench"
    role      = "runner"
    client_id = local.client_id
  }

  metadata_startup_script = templatefile("${path.module}/scripts/setup-runner.sh", {
    build_id              = random_id.build.hex,
    client_id             = local.client_id,
    client_repository_url = var.client_repository_url,
  })
}
