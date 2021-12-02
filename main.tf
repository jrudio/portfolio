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

resource "google_storage_bucket" "portfolio-caddy-assets" {
  name = "portfolio-caddy-assets"
  location = "us-west1"
  versioning {
    enabled = true
  }
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

  network_interface {
    network = "default"

    access_config {
    }
  }

  metadata_startup_script = "wget ${var.startup_script_url} && chmod +x startup_script.sh && caddy_cert_path=${google_storage_bucket.portfolio-caddy-assets.self_link} ./startup_script.sh"
}