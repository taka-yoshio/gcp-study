resource "google_artifact_registry_repository" "this" {
  project       = var.project
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = "DOCKER"
}
