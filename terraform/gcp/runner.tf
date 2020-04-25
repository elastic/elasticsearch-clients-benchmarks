resource "google_compute_instance" "runner" {
  name         = local.runner_instance_name
  description  = "bench-runner-${local.client_name}"
  machine_type = var.instance_type_runner

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
    group         = "bench"
    role          = "runner"
    client_name   = local.client_name
    client_commit = local.client_commit
  }

  metadata_startup_script = module.setup_runner.startup_script

  service_account {
    scopes = ["userinfo-email", "storage-ro"]
  }
}

module "setup_runner" {
  source = "../modules/setup/runner"

  build_id      = random_id.build.hex
  client_image  = var.client_image
  client_name   = local.client_name
  client_commit = local.client_commit

  data_source              = "/benchmarks-data"
  target_urls              = join(",", local.cluster_urls)
  target_service_type      = "elasticsearch"
  target_service_name      = "elasticsearch"
  target_service_version   = var.elasticsearch_version
  target_service_os_family = split("-", var.instance_image)[0]

  cloud_provider      = "gcp"
  cloud_region        = var.instance_region
  cloud_zone          = var.instance_zone
  cloud_instance_name = local.runner_instance_name
  cloud_machine_type  = var.instance_type_runner

  reporting_url      = var.reporting_url
  reporting_username = var.reporting_username
  reporting_password = var.reporting_password
}
