data "google_project" "project" {}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "artifact_registry" {
  source        = "./modules/artifact_registry"
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
}

module "cloud_sql" {
  source        = "./modules/cloud_sql"
  project_id    = var.project_id
  instance_name = "my-sql-instance"
  region        = var.region
  db_name       = "humans"
  network_name  = module.custom_vpc.network_name

  depends_on = [
    module.private_service_access
  ]
}

module "cloud_run" {
  source                   = "./modules/cloud_run"
  service_name             = "gcp-study-app"
  location                 = var.region
  bucket_name              = module.cloud_storage.bucket_name
  image                    = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/gcp-study-app@sha256:${var.app_image_digest}"
  instance_connection_name = module.cloud_sql.connection_name
  db_name                  = var.db_name
  vpc_connector_id         = module.vpc_connector.id

  depends_on = [
    module.vpc_connector
  ]
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
  security_policy_link   = module.cloud_armor.self_link
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
  location    = var.storage_location
}

module "custom_vpc" {
  source          = "./modules/vpc"
  project_id      = var.project_id
  network_name    = "gcp-study"
  subnet_name     = "my-custom-subnet"
  subnet_ip_range = "10.0.1.0/24"
  subnet_region   = var.region
}

module "private_service_access" {
  source       = "./modules/private_service_access"
  project_id   = var.project_id
  network_name = module.custom_vpc.network_name
}

module "vpc_connector" {
  source       = "./modules/vpc_connector"
  project_id   = var.project_id
  name         = "my-vpc-connector"
  region       = var.region
  network_name = module.custom_vpc.network_name
}

module "cloud_armor" {
  source       = "./modules/cloud_armor"
  project_id   = var.project_id
  policy_name  = "ip-whitelist-policy"
  allowed_ips  = var.allowed_ip_list
}

module "bigquery" {
  source     = "./modules/bigquery"
  project_id = "terraform-study-465601"
  dataset_id = "gcp_study_dataset"
  table_id   = "humans"
  location   = "asia-northeast1"
}

module "gke" {
  source               = "./modules/gke"
  project_id           = var.project_id
  cluster_name         = "my-gke-cluster"
  region               = var.region
  network_self_link    = module.custom_vpc.network_self_link
  subnetwork_self_link = module.custom_vpc.subnetwork_self_link

  depends_on = [
    module.custom_vpc
  ]
}

