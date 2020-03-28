# Pass on the command line with -var client_repository_url=https://github.com/elastic/foo
variable "client_repository_url" {
  type        = string
  description = "The Elasticsearch language client Github repository URL"

  validation {
    condition     = can(regex("^https://github.com/elastic/.+", var.client_repository_url))
    error_message = "The client_repository_url value must point to a Github repository in the @elastic organization."
  }
}

variable "server_count" {
  type        = number
  description = "The number of Elasticsearch nodes in the cluster"
  default     = 1
}

variable "instance_type_server" {
  description = "The instance type"
  default     = "n2-standard-8"
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
  client_id = replace(var.client_repository_url, "https://github.com/elastic/", "")
}
