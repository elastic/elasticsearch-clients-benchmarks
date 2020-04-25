output "startup_scripts" {
  value = [
    for startup_script in data.template_file.startup_script :
    startup_script.rendered
  ]
}

output "filebeat_config" {
  value = data.template_file.filebeat_config.rendered
}

output "metricbeat_config" {
  value = data.template_file.metricbeat_config.rendered
}
