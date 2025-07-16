data "google_project" "project" {}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "artifact_registry" {
  source        = "./modules/artifact_registry"
  project       = var.project_id
  location      = var.region
  repository_id = "docker-repo"
}

module "cloud_sql" {
  source        = "./modules/cloud_sql"
  instance_name = "my-sql-instance"
  region        = var.region
  db_name       = var.db_name
}

module "cloud_run" {
  source       = "./modules/cloud_run"
  service_name = "gcp-study-app"
  location     = var.region
  bucket_name  = module.cloud_storage.bucket_name
  image        = "${var.region}-docker.pkg.dev/${var.project_id}/docker-repo/gcp-study-app@sha256:${var.app_image_digest}"
  instance_connection_name = module.cloud_sql.connection_name
  db_name                  = var.db_name
}

module "secrets_manager_iam" {
  source = "./modules/secrets_manager"
  project_id                 = var.project_id
  secret_names               = ["db_user", "db_password"]
  member_service_account_email = var.service_account_email
}

module "load_balancer" {
  source                 = "./modules/load_balancer"
  project_id             = var.project_id
  domain_name            = var.domain_name
  cloud_run_service_name = module.cloud_run.service_name
  location               = module.cloud_run.location
}

module "dns" {
  source            = "./modules/dns"
  managed_zone_name = "yoshio-study-com"
  domain_name       = var.domain_name
  load_balancer_ip  = module.load_balancer.load_balancer_ip
}

module "cloud_storage" {
  source      = "./modules/cloud_storage"
  bucket_name = "pdf-uploads-${var.project_id}"
  location    = "ASIA-NORTHEAST1"
}
