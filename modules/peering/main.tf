terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {}
}

provider "google" {
  project = "inner-replica-417201"
}

resource "google_compute_network_peering" "america_europe_peering" {
  name         = "america-to-europe-peering"
  network      = var.peering_config.america_network_id
  peer_network = var.peering_config.europe_network_id
}

resource "google_compute_network_peering" "europe_america_peering" {
  name         = "europe-to-america-peering"
  network      = var.peering_config.europe_network_id
  peer_network = var.peering_config.america_network_id
}

