
resource "google_storage_bucket" "this" {
  name          = "web-app-assets-${var.project_id}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}
