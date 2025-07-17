output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.default.name
}

output "network_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.default.self_link
}

output "subnetwork_self_link" {
  description = "The self-link of the subnetwork"
  value       = google_compute_subnetwork.default.self_link
}
