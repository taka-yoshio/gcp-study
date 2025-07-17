variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
}

variable "domain_name" {
  description = "Cloud Runに割り当てるカスタムドメイン名"
  type        = string
}

variable "cloud_run_service_name" {
  description = "接続先のCloud Runサービス名"
  type        = string
}

variable "location" {
  description = "Cloud Runサービスが存在するリージョン"
  type        = string
}

variable "security_policy_link" {
  type    = string
  default = null
}
