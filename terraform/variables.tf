variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
}

variable "region" {
  description = "GCPリージョン"
  type        = string
  default     = "asia-northeast1"
}

variable "app_image_digest" {
  description = "gcp-study-appのDockerイメージのSHA256ダイジェスト"
  type        = string
}

variable "service_account_email" {
  description = "Cloud Runが使用するサービスアカウントのメールアドレス"
  type        = string
}

variable "db_name" {
  description = "データベース名"
  type        = string
  default     = "humans"
}

variable "domain_name" {
  description = "ドメイン名"
  type        = string
}

variable "allowed_ip_list" {
  description = "Cloud Armorで許可するIPアドレスのリスト"
  type        = list(string)
  default     = []
}

variable "repository_id" {
  description = "Artifact Registryのリポジトリ名"
  type        = string
  default     = "docker-repo"
}

variable "storage_location" {
  description = "Cloud Storageのロケーション"
  type        = string
  default     = "ASIA-NORTHEAST1"
}