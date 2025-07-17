resource "google_vpc_access_connector" "default" {
  project      = var.project_id
  name         = var.name
  region       = var.region
  network      = var.network_name
  ip_cidr_range = "10.8.0.0/28"
  machine_type = "e2-micro"
  min_instances = 2
  max_instances = 3
}
