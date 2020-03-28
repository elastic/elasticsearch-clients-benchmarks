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

output "server_gcloud_ssh_commands" {
  value = [
    for instance in google_compute_instance.server :
    "gcloud beta compute ssh --zone '${var.instance_zone}' '${instance.name}' --project 'elastic-clients'"
  ]
}
