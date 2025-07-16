variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
}

variable "network_name" {
  description = "VPCネットワークの名前"
  type        = string
}

variable "subnet_name" {
  description = "サブネットの名前"
  type        = string
}

variable "subnet_ip_range" {
  description = "サブネットのIPアドレス範囲"
  type        = string
}

variable "subnet_region" {
  description = "サブネットを作成するリージョン"
  type        = string
}