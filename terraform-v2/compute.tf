resource "google_service_account" "web_server" {
  account_id   = "web-server-sa"
  display_name = "Web Server Service Account"
}

resource "google_secret_manager_secret_iam_member" "web_server_secret_access" {
  secret_id = google_secret_manager_secret.this.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web_server.email}"
}

resource "google_compute_instance_template" "this" {
  name_prefix  = "web-server-template-"
  machine_type = var.machine_type
  region       = var.region

  tags = ["web-server"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.this.id
    subnetwork = google_compute_subnetwork.this.id
  }

  metadata = {
    secret_id          = "db-password"
    db_connection_name = google_sql_database_instance.this.connection_name
    bucket_url         = google_storage_bucket.this.url
  }

  metadata_startup_script = <<-EOF
    #! /bin/bash
    apt-get update
    apt-get install -y nginx jq

    # Fetch the secret name from metadata
    SECRET_ID=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/secret_id)

    # Fetch the DB connection name from metadata
    DB_CONNECTION_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_connection_name)

    # Fetch the bucket URL from metadata
    BUCKET_URL=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/bucket_url)

    # Fetch the secret payload
    DB_PASSWORD=$(gcloud secrets versions access latest --secret="$SECRET_ID")

    service nginx start
    echo "Hello from $(hostname). DB Password: $${DB_PASSWORD:0:4}***. DB Connection Name: $${DB_CONNECTION_NAME}. Bucket URL: $${BUCKET_URL}" > /var/www/html/index.html
  EOF

  service_account {
    email  = google_service_account.web_server.email
    scopes = ["cloud-platform"]
  }


  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "this" {
  name               = "web-server-mig"
  region             = var.region
  base_instance_name = "web-server"

  version {
    instance_template = google_compute_instance_template.this.id
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 3
    max_unavailable_fixed = 0
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    port = 80
  }
}

resource "google_compute_region_autoscaler" "this" {
  name   = "web-server-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.this.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}
