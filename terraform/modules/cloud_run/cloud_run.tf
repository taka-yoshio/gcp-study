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
          name = "DB_USER"
          value_from {
            secret_key_ref {
              name = "db_user" # Secret Managerに登録したユーザー名用のシークレット名
              key  = "latest"
            }
          }
        }
        env {
          name = "DB_PASS"
          value_from {
            secret_key_ref {
              name = "db_password" # Secret Managerに登録したパスワード用のシークレット名
              key  = "latest"
            }
          }
        }
        env {
          name  = "DB_NAME"
          value = var.db_name # DB名はシークレットではないので、今まで通りでOK
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
