resource "google_cloud_run_service" "this" {
  name     = var.service_name
  location = var.location

  template {
    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = var.instance_connection_name
        "run.googleapis.com/ingress"            = "internal-and-cloud-load-balancing"
      }
    }

    spec {
      service_account_name = "161116822257-compute@developer.gserviceaccount.com"

      containers {
        image = var.image

        resources {
          limits = {
            memory = var.memory
            cpu    = var.cpu
          }
        }

        env {
          name  = "INSTANCE_CONNECTION_NAME"
          value = var.instance_connection_name
        }

        env {
          name = "DB_USER"
          value_from {
            secret_key_ref {
              name = "db_user"
              key  = "latest"
            }
          }
        }

        env {
          name = "DB_PASS"
          value_from {
            secret_key_ref {
              name = "db_password"
              key  = "latest"
            }
          }
        }

        env {
          name  = "DB_NAME"
          value = var.db_name
        }

        env {
          name  = "BUCKET_NAME"
          value = var.bucket_name
        }

        volume_mounts {
          name       = "sa-key-secret"
          mount_path = "/secrets"
        }
      }

      volumes {
        name = "sa-key-secret"
        secret {
          secret_name = "sa-key-storage-upload-prod"
          items {
            key  = "latest"
            path = "sa-key.json"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
