output "load_balancer_ip" {
  description = "ロードバランサの外部IPアドレス"
  value       = google_compute_global_address.default.address
}