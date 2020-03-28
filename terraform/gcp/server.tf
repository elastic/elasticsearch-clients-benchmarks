resource "google_compute_instance" "server" {
  name         = "bench-server-${random_id.build.hex}-${random_id.server_instance[count.index].hex}"
  description  = "bench-server-${local.client_id}-${format("%03d", count.index + 1)}"
  machine_type = var.instance_type_server

  count = var.node_count

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network    = google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.default.self_link
    network_ip = count.index == 0 ? google_compute_address.master.address : null
    access_config {}
  }

  tags = ["allow-ssh"]

  labels = {
    group     = "bench"
    role      = "server"
    client_id = local.client_id
  }

  metadata_startup_script = templatefile("${path.module}/scripts/setup-server.sh", {
    build_id  = random_id.build.hex,
    client_id = local.client_id,
    server_nr = count.index + 1,
    master_ip = google_compute_address.master.address,
  })
}
