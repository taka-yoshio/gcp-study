provider "google" {
  project = "terraform-study-465601"
  region  = "asia-northeast1"
}

module "artifact_registry" {
  source        = "./modules/artifact_registry"
  project       = "terraform-study-465601"
  location      = "asia-northeast1"
  repository_id = "docker-repo"
}

module "cloud_sql" {
  source        = "./modules/cloud_sql"
  instance_name = "my-sql-instance"
  region        = "asia-northeast1"
  db_name       = "testdb"
  db_user       = "user"
  db_password   = "password"
}

module "cloud_run" {
  source       = "./modules/cloud_run"
  service_name = "gcp-study-app"
  location     = "asia-northeast1"
  image        = "asia-northeast1-docker.pkg.dev/terraform-study-465601/docker-repo/gcp-study-app@sha256:${var.app_image_digest}"
  instance_connection_name = module.cloud_sql.connection_name
  db_user                  = "user"
  db_pass                  = "password"
  db_name                  = "testdb"
}
