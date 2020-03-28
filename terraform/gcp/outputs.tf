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
