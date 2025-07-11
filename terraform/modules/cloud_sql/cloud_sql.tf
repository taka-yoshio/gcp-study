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
  name     = var.db_user
  password = var.db_password
  instance = google_sql_database_instance.default.name
}
