variable "client_image" {
  type        = string
  description = "The fully qualified Docker image with the Elasticsearch language client"

  validation {
    condition     = can(regex("[[:ascii:]]:[[:alnum:]]+$", var.client_image))
    error_message = "The value must contain a fully qualified Docker image: <NAME>:<TAG>."
  }
}

variable "reporting_url" {
  type        = string
  description = "Full URL for the reporting Elasticsearch cluster, including username:password"
}

variable "reporting_username" {
  type        = string
  description = "Username for authenticating to the reporting Elasticsearch cluster"
  default     = "elastic"
}

variable "reporting_password" {
  type        = string
  description = "Password for authenticating to the reporting Elasticsearch cluster"
}

variable "elasticsearch_version" {
  description = "The Elasticsearch version"
  default     = "7.7.0"
}

variable "node_count" {
  type        = number
  description = "The number of Elasticsearch nodes in the cluster"
  default     = 1
}

variable "target_type" {
  type        = string
  description = "The type of the target system (elasticsearch, nginx)"
  default     = "elasticsearch"

  validation {
    condition     = contains(["elasticsearch", "nginx"], var.target_type)
    error_message = "Unsupported target type, must be one of [elasticsearch, nginx]."
  }
}

variable "instance_type_target" {
  description = "The instance type for Elasticsearch nodes"
  default     = "n2-standard-8"
}

variable "instance_type_runner" {
  description = "The instance type for the client runner"
  default     = "n2-standard-4"
}

variable "instance_image" {
  description = "The instance OS image"
  default     = "ubuntu-1804-lts"
}

variable "instance_region" {
  description = "The GCP region where to create the instance"
  default     = "europe-west1"
}

variable "instance_zone" {
  description = "The GCP zone where to create the instance"
  default     = "europe-west1-b"
}

variable "instance_lifetime" {
  description = "The maximum lifetime for the instance; it will self-destruct afterwards"
  default     = "2h"
}

locals {
  runner_instance_name = "bench-runner-${random_id.build.hex}-${random_id.runner.hex}"

  client_image_parts = split("/", var.client_image)
  client_image_name  = local.client_image_parts[length(local.client_image_parts) - 1]

  client_name   = regex("([[:ascii:]]+):.+", local.client_image_name)[0]
  client_commit = regex(".+:([[:alnum:]]+)", local.client_image_name)[0]

  cluster_urls = [
    for instance in google_compute_instance.target :
    "http://${instance.network_interface.0.network_ip}:9200"
  ]

  target_types = ["elasticsearch", "nginx"]
}
