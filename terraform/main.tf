data "google_project" "project" {}

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
  db_name       = "humans"
}

module "cloud_run" {
  source       = "./modules/cloud_run"
  service_name = "gcp-study-app"
  location     = "asia-northeast1"
  image        = "asia-northeast1-docker.pkg.dev/terraform-study-465601/docker-repo/gcp-study-app@sha256:${var.app_image_digest}"
  instance_connection_name = module.cloud_sql.connection_name
  db_name                  = "humans"
}

module "secrets_manager_iam" {
  source = "./modules/secrets_manager"
  project_id                 = "terraform-study-465601"
  secret_names               = ["db_user", "db_password"]
  member_service_account_email = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

module "load_balancer" {
  source                 = "./modules/load_balancer"
  project_id             = "terraform-study-465601"
  domain_name            = "yoshio-study.com"
  cloud_run_service_name = module.cloud_run.service_name
  location               = module.cloud_run.location
}

module "dns" {
  source            = "./modules/dns"
  managed_zone_name = "yoshio-study-com"
  domain_name       = "yoshio-study.com"
  load_balancer_ip  = module.load_balancer.load_balancer_ip
}

module "cloud_storage" {
  source      = "./modules/cloud_storage"
  bucket_name = "pdf-uploads-terraform-study-465601" # GCP全体でユニークな名前に変更してください
  location    = "ASIA-NORTHEAST1"
}