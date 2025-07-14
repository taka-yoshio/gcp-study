resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  for_each = toset(var.secret_names)

  project   = var.project_id
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = var.member_service_account_email
}