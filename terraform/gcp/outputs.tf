output "build_id" {
  value = random_id.build.hex
}

output "client_image" {
  value = var.client_image
}

output "client_name" {
  value = local.client_name
}

output "client_commit" {
  value = local.client_commit
}

output "cluster_urls" {
  value = local.cluster_urls
}

output "master_ip" {
  value = google_compute_address.master.address
}

output "runner_instance_name" {
  value = google_compute_instance.runner.name
}

output "target_public_ips" {
  value = [
    for instance in google_compute_instance.target :
    instance.network_interface.0.access_config.0.nat_ip
  ]
}

output "target_private_ips" {
  value = [
    for instance in google_compute_instance.target :
    instance.network_interface.0.network_ip
  ]
}

output "target_instance_names" {
  value = [
    for instance in google_compute_instance.target :
    instance.name
  ]
}

output "target_type" {
  value = var.target_type
}
