terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {}
}

provider "google" {
  project = "inner-replica-417201"
}

resource "google_compute_network" "asia_network" {
  name                    = var.asia_network_config.network_name
  auto_create_subnetworks = var.asia_network_config.auto_create_subnetworks
}

resource "google_compute_subnetwork" "asia_subnet" {
  name                     = var.asia_network_config.subnet_name
  network                  = google_compute_network.asia_network.id
  ip_cidr_range            = var.asia_network_config.subnet_cidr
  region                   = var.asia_network_config.region
  private_ip_google_access = var.asia_network_config.private_ip_google_access
}

resource "google_compute_firewall" "asia_allow_rdp" {
  name    = var.asia_network_config.firewall.name
  network = google_compute_network.asia_network.id

  allow {
    protocol = "tcp"
    ports    = var.asia_network_config.firewall.ports
  }

  source_ranges = var.asia_network_config.firewall.source_ranges
  target_tags   = var.asia_network_config.firewall.target_tags
}

resource "google_compute_instance" "asia_vm1" {
  depends_on   = [google_compute_subnetwork.asia_subnet]
  name         = var.asia_vm_config.name
  machine_type = var.asia_vm_config.machine_type
  zone         = var.asia_vm_config.zone

  boot_disk {
    initialize_params {
      image = var.asia_vm_config.image_family
    }
  }

  network_interface {
    network    = google_compute_network.asia_network.id
    subnetwork = google_compute_subnetwork.asia_subnet.id

    access_config {
      // Not assigned a public IP
    }
  }

  tags = var.asia_vm_config.tags
}

data "google_secret_manager_secret_version" "vpn_secret" {
  secret  = "vpn-shared-secret"
  version = "latest"
}

resource "google_compute_vpn_gateway" "asia_vpn_gateway" {
  name    = "asia-vpn-gateway"
  network = google_compute_network.asia_network.id
  region  = var.asia_network_config.region
}

resource "google_compute_address" "asia_vpn_ip" {
  name   = "asia-vpn-ip"
  region = var.asia_network_config.region
}

resource "google_compute_vpn_tunnel" "asia_vpn_tunnel" {
  name               = "asia-to-europe-tunnel"
  region             = var.asia_network_config.region
  target_vpn_gateway = google_compute_vpn_gateway.asia_vpn_gateway.id
  peer_ip            = var.peer_ip
  shared_secret      = data.google_secret_manager_secret_version.vpn_secret.secret_data
  ike_version        = 2

  local_traffic_selector  = var.local_traffic_selector
  remote_traffic_selector = var.remote_traffic_selector

  depends_on = [
    google_compute_forwarding_rule.esp,
    google_compute_forwarding_rule.udp500,
    google_compute_forwarding_rule.udp4500
  ]
}

resource "google_compute_route" "asia_vpn_route" {
  name                = "asia-to-europe-route"
  network             = google_compute_network.asia_network.id
  dest_range          = var.remote_traffic_selector[0]
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.asia_vpn_tunnel.id
  priority            = 1000
}

resource "google_compute_forwarding_rule" "esp" {
  name        = "asia-vpn-esp"
  region      = var.asia_network_config.region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.asia_vpn_ip.address
  target      = google_compute_vpn_gateway.asia_vpn_gateway.self_link
}

resource "google_compute_forwarding_rule" "udp500" {
  name        = "asia-vpn-udp500"
  region      = var.asia_network_config.region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.asia_vpn_ip.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.asia_vpn_gateway.self_link
}

resource "google_compute_forwarding_rule" "udp4500" {
  name        = "asia-vpn-udp4500"
  region      = var.asia_network_config.region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.asia_vpn_ip.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.asia_vpn_gateway.self_link
}

output "network_id" {
  value = google_compute_network.asia_network.id
}

output "asia_vpn_ip_address" {
  
  value = google_compute_address.asia_vpn_ip.address
}

