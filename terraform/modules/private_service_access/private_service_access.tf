resource "google_compute_global_address" "private_ip_alloc" {
  project       = var.project_id
  name          = "private-service-access-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "projects/${var.project_id}/global/networks/${var.network_name}"
}

resource "google_service_networking_connection" "default" {
  network                 = "projects/${var.project_id}/global/networks/${var.network_name}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}
