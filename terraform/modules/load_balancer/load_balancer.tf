# 1. 静的なグローバルIPアドレスを予約
resource "google_compute_global_address" "default" {
  project = var.project_id # どのGCPプロジェクトに、そのIPアドレスを作りますか？を指定
  name    = "lb-static-ip" # GCP上で実際に作られるIPアドレスに、名前をつける
}

# 2. ドメイン用のGoogleマネージドSSL証明書を作成
resource "google_compute_managed_ssl_certificate" "default" {
  project = var.project_id
  name    = "custom-domain-cert"
  managed { # この証明書は、Googleに管理を任せる
    domains = [var.domain_name] # どのドメイン名に対する証明書ですか？を指定
  }
}

# 3. ロードバランサが接続するための『行き先』を登録
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  project               = var.project_id
  name                  = "cloudrun-neg"
  # このグループが、どのような種類の接続先をまとめるものかを指定、
  # SERVERLESSは、Cloud Runのようなサーバーレスサービスですよ」と指定
  network_endpoint_type = "SERVERLESS"
  region                = var.location
  #️network_endpoint_typeでSERVERLESSを選んだので、具体的にどのサーバーレスサービスに接続するかを指定
  # どのCloud Runサービスに接続するかを、サービス名を指定
  cloud_run {
    service = var.cloud_run_service_name
  }
}

# 4. 前の手順で作った「行き先」に対して、「その行き先にはどういうルールで接続するか」という詳細設定を定義
#    Cloud Runに接続するためのバックエンドサービスを作って。細かいルールは、Googleが推奨する一番標準的な設定で全部お任せ
resource "google_compute_backend_service" "default" {
  project                 = var.project_id
  name                    = "cloudrun-backend-service"
  protocol                = "HTTP" # ロードバランサと裏方（今回はCloud Run）が通信する際の言語（プロトコル）を指定
  load_balancing_scheme   = "EXTERNAL_MANAGED" # どのような種類のロードバランサで使われるかを指定.外部向けの、Google管理のロードバランサで使いますよ
  # このバックエンドサービスが、具体的にどの接続先グループを管理するのかを指定
  # 「このバックエンドサービスが管理するグループは、先ほど手順3で作ったサーバーレスNEG（serverless_neg）ですよ」と紐づけ
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

# 5. URLマップを作成（すべてのトラフィックをバックエンドに流す）
#.   ロードバランサの交通整理ルールとして、『どんなURLへのアクセスが来ても、すべて先ほど設定したCloud Run用のバックエンドサービスに送る』というシンプルなルールブックを作成
resource "google_compute_url_map" "default" {
  project         = var.project_id
  name            = "lb-url-map"
  default_service = google_compute_backend_service.default.id #特にルールに合致しない、すべてのアクセスはここに送ってくださいと指定
}

# 6. HTTPSプロキシを作成
resource "google_compute_target_https_proxy" "default" {
  project          = var.project_id
  name             = "https-proxy"
  url_map          = google_compute_url_map.default.id # どの交通整理ルールブックを使うかを指定
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id] # どの証明書（SSL証明書）を使うかを指定
}

# 7. グローバル転送ルールを作成（IPアドレスとプロキシを接続）HTTPSプロキシを1つ作成
resource "google_compute_global_forwarding_rule" "default" {
  project               = var.project_id
  name                  = "https-forwarding-rule"
  target                = google_compute_target_https_proxy.default.id # この入り口に来たアクセスを、どこに（誰に）渡しますか？」という転送先を指定
  ip_address            = google_compute_global_address.default.address # 「どのIPアドレスを、このルールの入り口にしますか？」という場所の指定
  port_range            = "443" #「そのIPアドレスの、どのポート番号でアクセスを待ち受けますか？」という指定。htttpsの443を指定
  load_balancing_scheme = "EXTERNAL_MANAGED" # の転送ルールが、外部公開用のロードバランサのものであることを改めて示して
}
