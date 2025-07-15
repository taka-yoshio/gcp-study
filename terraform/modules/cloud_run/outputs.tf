output "service_name" {
  description = "Cloud Runサービスの名前"
  value       = google_cloud_run_service.this.name
}

output "location" {
  description = "Cloud Runサービスのロケーション"
  value       = google_cloud_run_service.this.location
}
