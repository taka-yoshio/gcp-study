data "google_secret_manager_secret_version" "db_user" {
  secret = "db_user"
}

# Secret Managerからパスワードを取得
data "google_secret_manager_secret_version" "db_password" {
  secret = "db_password"
}

resource "google_sql_database_instance" "default" {
  name             = var.instance_name
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = var.tier
  }
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "default" {
  name     = data.google_secret_manager_secret_version.db_user.secret_data
  password = data.google_secret_manager_secret_version.db_password.secret_data
  instance = google_sql_database_instance.default.name
}

