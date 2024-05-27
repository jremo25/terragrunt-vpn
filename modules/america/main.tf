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
  

resource "google_compute_network" "americas_network" {
  name                    = var.americas_network_config.network_name
  auto_create_subnetworks = var.americas_network_config.auto_create_subnets
}

resource "google_compute_subnetwork" "americas_subnet" {
  for_each = var.americas_network_config.subnet_configs

  name                     = each.value.name
  network                  = google_compute_network.americas_network.id
  ip_cidr_range            = each.value.cidr
  region                   = each.value.region
  private_ip_google_access = each.value.private_ip_access
}

resource "google_compute_instance" "america_vm" {
  for_each = { for vm in var.americas_network_config.vm_details : vm.name => vm }

  depends_on   = [google_compute_subnetwork.americas_subnet]
  name         = each.value.name
  machine_type = each.value.machine_type
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = each.value.image_family
    }
  }

  network_interface {
    network    = google_compute_network.americas_network.id
    subnetwork = google_compute_subnetwork.americas_subnet[each.value.subnet_name].id

    access_config {
      // Not assigned a public IP
    }
  }

  tags = each.value.tags
}

resource "google_compute_firewall" "america_firewall" {
  name    = var.americas_network_config.firewall.name
  network = google_compute_network.americas_network.id

  allow {
    protocol = "tcp"
    ports    = var.americas_network_config.firewall.protocols_ports.tcp
  }

  source_ranges = var.americas_network_config.firewall.source_ranges
  target_tags   = var.americas_network_config.firewall.target_tags
}

output "network_id" {
  value = google_compute_network.americas_network.id
}

