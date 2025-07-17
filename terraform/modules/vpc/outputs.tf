output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.default.name
}
