variable "instance_name" {
  type        = string
  description = "Cloud SQL instance name"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "tier" {
  type        = string
  default     = "db-f1-micro"
  description = "Cloud SQL tier"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_user" {
  type        = string
  description = "Database user"
}

variable "db_password" {
  type        = string
  description = "Database password"
}
