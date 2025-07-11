resource "google_cloud_run_service" "this" {
  name     = var.service_name
  location = var.location

  template {
    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = var.instance_connection_name
      }
    }

    spec {
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
          name  = "DB_USER"
          value = var.db_user
        }

        env {
          name  = "DB_PASS"
          value = var.db_pass
        }

        env {
          name  = "DB_NAME"
          value = var.db_name
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
