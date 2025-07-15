resource "google_storage_bucket" "default" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = true # 中身が空でなくてもterraform destroyできるようにする設定

  # 均一なバケットレベルのアクセス制御（推奨）
  uniform_bucket_level_access = true

  # 7日後にオブジェクトを削除するライフサイクルルール
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
}
