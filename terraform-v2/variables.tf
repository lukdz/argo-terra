variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone to deploy resources"
  type        = string
  default     = "us-central1-a"
}

variable "credentials_file" {
  description = "Path to the GCP credentials JSON file"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the web servers"
  type        = string
  default     = "e2-micro"
}

variable "db_tier" {
  description = "The machine type for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "domain_name" {
  description = "The domain name for the application"
  type        = string
  default     = "example.com"
}
