output "load_balancer_ip" {
  description = "The public IP address of the Load Balancer"
  value       = google_compute_global_address.default.address
}

output "database_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.this.connection_name
}

output "database_private_ip" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.this.private_ip_address
}

output "bucket_name" {
  description = "The name of the GCS bucket"
  value       = google_storage_bucket.this.name
}
