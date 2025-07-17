resource "google_compute_security_policy" "default" {
  project = var.project_id
  name    = var.policy_name

  rule {
    action   = "allow"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.allowed_ips
      }
    }
    description = "許可IPリストからのアクセスを許可"
  }

  rule {
    action   = "deny(403)"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "その他のアクセスをすべて拒否"
  }
}
