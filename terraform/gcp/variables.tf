variable "instance_type" {
  description = "The instance type"
  default     = "f1-micro"
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
