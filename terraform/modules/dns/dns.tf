# インターネットの住所録に、あなたのドメインの住所を登録する
resource "google_dns_record_set" "a_record" {
  name         = "${var.domain_name}."
  type         = "A" # 登録する情報の種類を指定、Aレコードは、ドメイン名をIPアドレスに結びつける、最も基本的なレコードタイプ
  ttl          = 3600 # 1時間はこの情報を覚えておいていいよ（キャッシュしていいよ）」
  managed_zone = var.managed_zone_name
  rrdatas      = [var.load_balancer_ip]
}
