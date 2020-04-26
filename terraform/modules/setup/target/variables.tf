variable "build_id" {
  type        = string
  description = "The benchmarking run ID"
}

variable "client_name" {
  type        = string
  description = "The name of the client"
}

variable "client_image" {
  type        = string
  description = "The fully qualified Docker image with the client"
}

variable "client_commit" {
  type        = string
  description = "The client commit SHA1"
}

variable "target_type" {
  type        = string
  description = "The type of the target system (elasticsearch, nginx)"
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

variable "master_ip" {
  type        = string
  description = "The IP of the Elasticsearch cluster master node"
}

variable "reporting_url" {
  type        = string
  description = "Full URL for the reporting Elasticsearch cluster, including username:password"
}

variable "reporting_username" {
  type        = string
  description = "Username for authenticating to the reporting Elasticsearch cluster"
}

variable "reporting_password" {
  type        = string
  description = "Password for authenticating to the reporting Elasticsearch cluster"
}
