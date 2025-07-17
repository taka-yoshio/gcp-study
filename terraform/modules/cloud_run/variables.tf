# modules/cloud_run/variables.tf
variable "service_name" {
  type        = string
  description = "Name of the Cloud Run service"
}

variable "location" {
  type        = string
  description = "Location for the Cloud Run service"
}

variable "image" {
  type        = string
  description = "Docker image URL"
}

variable "memory" {
  type        = string
  description = "Memory allocation for the service"
  default     = "512Mi"
}

variable "cpu" {
  type        = string
  description = "CPU allocation for the service"
  default     = "1"
}

variable "instance_connection_name" {
  type        = string
  description = "Cloud SQL connection name"
}

variable "db_name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "vpc_connector_id" {
  description = "VPCアクセスコネクタのID"
  type        = string
  default     = null
}
