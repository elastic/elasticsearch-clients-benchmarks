data "template_file" "startup_script" {
  template = file("${path.module}/${var.target_type}/scripts/startup.sh.tmpl")
  vars = {
    build_id = var.build_id

    client_name   = var.client_name
    client_image  = var.client_image
    client_commit = var.client_commit

    node_nr               = count.index + 1
    elasticsearch_version = var.elasticsearch_version
    master_ip             = var.master_ip

    nginx_config = data.local_file.nginx_config.content

    metricbeat_config = data.template_file.metricbeat_config.rendered
    filebeat_config   = data.template_file.filebeat_config.rendered
  }
  count = var.node_count
}

data "local_file" "nginx_config" {
  filename = "${path.module}/nginx/config/nginx.conf"
}

data "template_file" "metricbeat_config" {
  template = file("${path.module}/${var.target_type}/templates/metricbeat.yml")
  vars = {
    build_id = var.build_id

    client_name   = var.client_name
    client_image  = var.client_image
    client_commit = var.client_commit

    elasticsearch_version = var.elasticsearch_version

    reporting_elasticsearch_url      = var.reporting_url
    reporting_elasticsearch_username = var.reporting_username
    reporting_elasticsearch_password = var.reporting_password
  }
}

data "template_file" "filebeat_config" {
  template = file("${path.module}/${var.target_type}/templates/filebeat.yml")
  vars = {
    build_id = var.build_id

    client_name   = var.client_name
    client_image  = var.client_image
    client_commit = var.client_commit

    elasticsearch_version = var.elasticsearch_version

    reporting_elasticsearch_url      = var.reporting_url
    reporting_elasticsearch_username = var.reporting_username
    reporting_elasticsearch_password = var.reporting_password
  }
}
