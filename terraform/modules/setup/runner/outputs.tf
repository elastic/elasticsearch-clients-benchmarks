output "startup_script" {
  value = data.template_file.startup_script.rendered
}
