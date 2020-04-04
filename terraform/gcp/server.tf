resource "google_compute_instance" "server" {
  name         = "bench-server-${random_id.build.hex}-${random_id.server_instance[count.index].hex}"
  description  = "bench-server-${format("%03d", count.index + 1)}"
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
    group         = "bench"
    role          = "server"
    client_name   = local.client_name
    client_commit = local.client_commit
  }

  metadata_startup_script = templatefile("${path.module}/scripts/setup-server.sh", {
    build_id              = random_id.build.hex,
    elasticsearch_version = var.elasticsearch_version,
    client_image          = var.client_image,
    client_name           = local.client_name,
    client_commit         = local.client_commit,
    server_nr             = count.index + 1,
    master_ip             = google_compute_address.master.address,
  })
}
