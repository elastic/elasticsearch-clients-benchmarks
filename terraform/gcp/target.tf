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

  metadata_startup_script = templatefile("${path.module}/setup/target/startup.sh.tmpl", {
    build_id              = random_id.build.hex,
    elasticsearch_version = var.elasticsearch_version,
    client_image          = var.client_image,
    client_name           = local.client_name,
    client_commit         = local.client_commit,
    node_nr               = count.index + 1,
    master_ip             = google_compute_address.master.address,

    metricbeat_config = data.template_file.metricbeat_config.rendered,
    filebeat_config   = data.template_file.filebeat_config.rendered,
  })
}

data "template_file" "metricbeat_config" {
  template = file("${path.module}/setup/target/templates/metricbeat.yml")
  vars = {
    build_id                         = random_id.build.hex
    client_name                      = local.client_name
    reporting_elasticsearch_url      = var.reporting_url
    reporting_elasticsearch_username = var.reporting_username
    reporting_elasticsearch_password = var.reporting_password
  }
}

data "template_file" "filebeat_config" {
  template = file("${path.module}/setup/target/templates/filebeat.yml")
  vars = {
    build_id                         = random_id.build.hex
    client_name                      = local.client_name
    reporting_elasticsearch_url      = var.reporting_url
    reporting_elasticsearch_username = var.reporting_username
    reporting_elasticsearch_password = var.reporting_password
  }
}
