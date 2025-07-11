variable "project" {
  type        = string
  description = "GCP project ID"
}

variable "location" {
  type        = string
  description = "Location for the artifact registry"
}

variable "repository_id" {
  type        = string
  description = "Repository ID"
}

variable "description" {
  type        = string
  description = "Repository description"
  default     = "Docker repository"
}
