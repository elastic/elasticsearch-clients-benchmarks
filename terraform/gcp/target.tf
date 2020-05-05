resource "google_compute_instance" "target" {
  name         = "bench-target-${random_id.build.hex}-${random_id.target[count.index].hex}"
  description  = "bench-target-${format("%03d", count.index + 1)}"
  machine_type = var.instance_type_target

  count = var.node_count

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  scratch_disk {
    # count = var.target_type == "nginx" ? 0 : 1 // Do not create local SSD for Nginx
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
    role          = "target"
    client_name   = local.client_name
    client_commit = local.client_commit
  }

  metadata_startup_script = module.setup_target.startup_scripts[count.index]

  service_account {
    scopes = ["userinfo-email", "storage-ro", "compute-rw"]
  }
}

module "setup_target" {
  source = "../modules/setup/target"

  target_type = var.target_type

  elasticsearch_version = var.elasticsearch_version
  node_count            = var.node_count
  master_ip             = google_compute_address.master.address

  build_id      = random_id.build.hex
  client_name   = local.client_name
  client_image  = var.client_image
  client_commit = local.client_commit

  reporting_url      = var.reporting_url
  reporting_username = var.reporting_username
  reporting_password = var.reporting_password

  instance_lifetime = var.instance_lifetime
}
