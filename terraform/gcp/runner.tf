resource "google_compute_instance" "runner" {
  name         = "bench-runner-${random_id.build.hex}-${random_id.runner.hex}"
  description  = "bench-runner-${local.client_name}"
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
    group       = "bench"
    role        = "runner"
    client_name = local.client_name
  }

  metadata_startup_script = templatefile("${path.module}/scripts/setup-runner.sh", {
    build_id      = random_id.build.hex,
    client_image  = var.client_image,
    client_name   = local.client_name,
    client_commit = local.client_commit,
  })

  service_account {
    scopes = ["userinfo-email", "storage-ro"]
  }
}
