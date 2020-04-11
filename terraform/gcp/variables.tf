# Pass on the command line with -var client_image=https://github.com/elastic/foo
#
variable "client_image" {
  type        = string
  description = "The fully qualified Docker image with the Elasticsearch language client"

  validation {
    condition     = can(regex("[[:ascii:]]:[[:alnum:]]+$", var.client_image))
    error_message = "The value must contain a fully qualified Docker image: <NAME>:<TAG>."
  }
}

# Pass on the command line with -var reporting={url: https://...cloud.es.io:9243, password: foo}
#
variable "reporting" {
  type        = map(string)
  description = "Credentials and configurations for the reporting cluster"
  default     = { "username" : "elastic" }
}

variable "elasticsearch_version" {
  description = "The Elasticsearch version"
  default     = "7.6.2"
}

variable "node_count" {
  type        = number
  description = "The number of Elasticsearch nodes in the cluster"
  default     = 1
}

variable "instance_type_server" {
  description = "The instance type for Elasticsearch nodes"
  default     = "n2-standard-8"
}

variable "instance_type_runner" {
  description = "The instance type for the client runner"
  default     = "t1-micro"
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

locals {
  client_image_parts = split("/", var.client_image)
  client_image_name  = local.client_image_parts[length(local.client_image_parts) - 1]

  client_name   = regex("([[:ascii:]]+):.+", local.client_image_name)[0]
  client_commit = regex(".+:([[:alnum:]]+)", local.client_image_name)[0]
}
