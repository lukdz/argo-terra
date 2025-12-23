# Private Service Access for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.this.id
}

resource "google_service_networking_connection" "this" {
  network                 = google_compute_network.this.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "this" {
  name             = "web-app-db-instance"
  region           = var.region
  database_version = "POSTGRES_14"

  depends_on = [google_service_networking_connection.this]

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.this.id
    }

    backup_configuration {
      enabled = true
    }

    # High Availability
    availability_type = "REGIONAL"
  }
  deletion_protection = false # For POC purposes
}

resource "google_sql_database" "this" {
  name     = "webappdb"
  instance = google_sql_database_instance.this.name
}

resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "this" {
  name     = "webappuser"
  instance = google_sql_database_instance.this.name
  password = random_password.this.result
}

resource "google_secret_manager_secret" "this" {
  secret_id = "db-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "this" {
  secret      = google_secret_manager_secret.this.id
  secret_data = random_password.this.result
}

