resource "google_compute_instance" "server" {
  name         = "bench-server-${random_id.build_id.hex}"
  description  = "bench-server-${local.client_id}-${format("%03d", count.index + 1)}"
  machine_type = var.instance_type_server

  count = var.server_count

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {}
  }

  tags = ["allow-ssh"]

  labels = {
    group     = "bench"
    role      = "server"
    client_id = local.client_id
  }

  metadata_startup_script = data.template_file.setup_server[count.index].rendered
}

data "template_file" "setup_server" {
  template = file("${path.module}/scripts/setup-server.sh")
  count    = var.server_count
  vars = {
    build_id  = random_id.build_id.hex
    client_id = local.client_id
    server_nr = count.index + 1
  }
}
