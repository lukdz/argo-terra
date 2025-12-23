# Self-signed certificate for POC
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Should be replaced with a valid certificate in production
# TXT record for domain validation is recommended
resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = var.domain_name
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "google_compute_ssl_certificate" "this" {
  name        = "my-certificate"
  private_key = tls_private_key.this.private_key_pem
  certificate = tls_self_signed_cert.this.cert_pem
}

# Load Balancer Resources
resource "google_compute_global_address" "default" {
  name = "lb-ipv4-address"
}

resource "google_compute_health_check" "default" {
  name = "http-health-check"

  http_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "this" {
  name                  = "web-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.default.id]

  backend {
    group           = google_compute_region_instance_group_manager.this.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "this" {
  name            = "web-map"
  default_service = google_compute_backend_service.this.id
}

resource "google_compute_target_https_proxy" "this" {
  name             = "web-https-proxy"
  url_map          = google_compute_url_map.this.id
  ssl_certificates = [google_compute_ssl_certificate.this.id]
}

resource "google_compute_global_forwarding_rule" "this" {
  name       = "web-forwarding-rule"
  target     = google_compute_target_https_proxy.this.id
  port_range = "443"
  ip_address = google_compute_global_address.default.address
}

