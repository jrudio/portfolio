terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  region  = "us-west1"
  zone = "us-west1-b"
}

resource "google_service_account" "portfolio_service_account" {
  account_id = "portfolio-caddy-id-01"
  display_name = "portfolio caddy service account"
  description = "service account for ${resource.google_compute_instance.portfolio-server} instance"
}

data "google_iam_policy" "portfolio_iam_policy" {
  binding {
    role               = "roles/storage.objectViewer"
    members = [
      "serviceAccount:${google_service_account.portfolio_service_account.email}",
    ]
  }
}

resource "google_storage_bucket" "portfolio_caddy_assets" {
  name = "portfolio-caddy-assets"
  location = "us-west1"
  versioning {
    enabled = true
  }

  force_destroy = true
}

data "local_file" "portfolio_startup_script" {
  filename = "${path.module}/startup_script.sh"
}

data "local_file" "caddy_file" {
  filename = "${path.module}/Caddyfile"
}

resource "google_compute_instance" "portfolio-server" {
  name = "portfolio-caddy-server-1"
  machine_type = "f1-micro"
  zone = "us-west1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20211115"
    }
  }

  tags = [ "default-allow-http", "default-allow-https" ]

  network_interface {
    network = "default"

    access_config {
    }
  }

  # caddy_bucket is used for any existing certificates
  metadata_startup_script = "caddy_bucket=${resource.google_storage_bucket.portfolio_caddy_assets.url}; caddy_Caddyfile=${data.local_file.caddy_file.content}; ${data.local_file.portfolio_startup_script.content}"

  service_account {
    email = resource.google_service_account.portfolio_service_account.email
    scopes = [ "storage-full" ]
  }
}