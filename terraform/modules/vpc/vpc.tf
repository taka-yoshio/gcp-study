# VPCネットワークを作成
resource "google_compute_network" "default" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false # サブネットは手動で作成する
}

# サブネットを作成
resource "google_compute_subnetwork" "default" {
  project                  = var.project_id
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_ip_range
  region                   = var.subnet_region
  network                  = google_compute_network.default.id
}

# SSH(22), RDP(3389), ICMP(ping)を許可するファイアウォールルール
resource "google_compute_firewall" "allow_ssh_rdp_icmp" {
  project = var.project_id
  name    = "${var.network_name}-allow-ssh-rdp-icmp"
  network = google_compute_network.default.name
  
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"] # どこからでも
}