resource "google_compute_network" "this" {
  name                    = "web-app-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "web-app-private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.this.id
}

# Cloud Router and NAT for private instances to access the internet
resource "google_compute_router" "this" {
  name    = "web-app-router"
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  name                               = "web-app-nat"
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall rule to allow health checks from Google Load Balancer
resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check"
  network = google_compute_network.this.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["web-server"]
}

# Firewall rule to allow IAP (Identity-Aware Proxy) for SSH access
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = google_compute_network.this.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["web-server"]
}
