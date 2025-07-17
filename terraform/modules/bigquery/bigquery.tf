resource "google_bigquery_dataset" "default" {
  project    = var.project_id
  dataset_id = var.dataset_id
  location   = var.location
}

resource "google_bigquery_table" "default" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = var.table_id

  schema = jsonencode([
    {
      "name" : "Id",
      "type" : "STRING",
      "mode" : "NULLABLE"
    },
    {
      "name" : "Name",
      "type" : "STRING",
      "mode" : "NULLABLE"
    },
    {
      "name" : "Age",
      "type" : "INTEGER",
      "mode" : "NULLABLE"
    }
  ])
}
