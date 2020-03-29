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
  value = [
    for instance in google_compute_instance.server :
    "http://${instance.network_interface.0.network_ip}:9200"
  ]
}

output "master_ip" {
  value = google_compute_address.master.address
}

output "runner_instance_name" {
  value = google_compute_instance.runner.name
}

output "server_public_ips" {
  value = [
    for instance in google_compute_instance.server :
    instance.network_interface.0.access_config.0.nat_ip
  ]
}

output "server_private_ips" {
  value = [
    for instance in google_compute_instance.server :
    instance.network_interface.0.network_ip
  ]
}

output "server_instance_names" {
  value = [
    for instance in google_compute_instance.server :
    instance.name
  ]
}
