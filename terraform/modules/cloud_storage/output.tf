output "bucket_name" {
  description = "Cloud Storageバケットの名前"
  value       = google_storage_bucket.default.name
}
