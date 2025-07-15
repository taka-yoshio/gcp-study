variable "managed_zone_name" {
  description = "Cloud DNSのマネージドゾーン名"
  type        = string
}

variable "domain_name" {
  description = "カスタムドメイン名"
  type        = string
}

variable "load_balancer_ip" {
  description = "ロードバランサのIPアドレス"
  type        = string
}
