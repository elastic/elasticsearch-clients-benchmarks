data "template_file" "startup_script" {
  template = file("${path.module}/scripts/startup.sh.tmpl")
  vars = {
    build_id = var.build_id

    client_image  = var.client_image
    client_name   = var.client_name
    client_commit = var.client_commit

    data_source = var.data_source
    target_urls = var.target_urls

    target_service_type      = var.target_service_type
    target_service_name      = var.target_service_name
    target_service_version   = var.target_service_version
    target_service_os_family = var.target_service_os_family

    cloud_provider      = var.cloud_provider
    cloud_region        = var.cloud_region
    cloud_zone          = var.cloud_zone
    cloud_instance_name = var.cloud_instance_name
    cloud_machine_type  = var.cloud_machine_type
  }
}