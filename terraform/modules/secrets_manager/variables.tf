variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
}

variable "secret_names" {
  description = "IAMを付与するシークレット名のリスト"
  type        = list(string)
}

variable "member_service_account_email" {
  description = "権限を付与するサービスアカウントのメールアドレス"
  type        = string
}
