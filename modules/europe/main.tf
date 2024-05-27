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

resource "google_compute_network" "europe_network" {
  name                    = var.config.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "europe_subnet" {
  name                     = var.config.subnet_name
  network                  = google_compute_network.europe_network.id
  ip_cidr_range            = var.config.subnet_cidr
  region                   = var.config.region
  private_ip_google_access = true
}

resource "google_compute_firewall" "europe_http" {
  name    = "europe-http"
  network = google_compute_network.europe_network.id

  allow {
    protocol = "tcp"
    ports    = var.config.allowed_ports
  }

  source_ranges = var.config.ip_cidr_ranges
  target_tags   = var.config.tags
}

resource "google_compute_instance" "europe_vm" {
  depends_on   = [google_compute_subnetwork.europe_subnet]
  name         = var.config.vm_name
  machine_type = "e2-medium"
  zone         = var.config.zone

  boot_disk {
    initialize_params {
      image = var.config.image_family
    }
  }

  network_interface {
    network    = google_compute_network.europe_network.id
    subnetwork = google_compute_subnetwork.europe_subnet.id
    access_config {
      // Not assigned a public IP
    }
  }

  metadata = {
    startup-script = file("${path.module}/startup-script.sh")
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  tags = var.config.tags
}

data "google_secret_manager_secret_version" "vpn_secret" {
  secret  = "vpn-shared-secret"
  version = "latest"
}

resource "google_compute_vpn_gateway" "europe_vpn_gateway" {
  name    = "europe-vpn-gateway"
  network = google_compute_network.europe_network.id
  region  = var.config.region
}

resource "google_compute_address" "europe_vpn_ip" {
  name   = "europe-vpn-ip"
  region = var.config.region
}

###################
# resource "google_compute_vpn_tunnel" "europe_vpn_tunnel" {
#   name               = "europe-to-asia-tunnel"
#   region             = var.config.region
#   target_vpn_gateway = google_compute_vpn_gateway.europe_vpn_gateway.id
#   peer_ip            = var.peer_ip
#   shared_secret      = data.google_secret_manager_secret_version.vpn_secret.secret_data
#   ike_version        = 2

#   local_traffic_selector  = var.local_traffic_selector
#   remote_traffic_selector = var.remote_traffic_selector

#   depends_on = [
#     google_compute_forwarding_rule.esp,
#     google_compute_forwarding_rule.udp500,
#     google_compute_forwarding_rule.udp4500
#   ]
# }

# resource "google_compute_route" "europe_vpn_route" {
#   name                = "europe-to-asia-route"
#   network             = google_compute_network.europe_network.id
#   dest_range          = var.remote_traffic_selector[0]
#   next_hop_vpn_tunnel = google_compute_vpn_tunnel.europe_vpn_tunnel.id
#   priority            = 1000
# }

# resource "google_compute_forwarding_rule" "esp" {
#   name        = "europe-vpn-esp"
#   region      = var.config.region
#   ip_protocol = "ESP"
#   ip_address  = google_compute_address.europe_vpn_ip.address
#   target      = google_compute_vpn_gateway.europe_vpn_gateway.self_link
# }

# resource "google_compute_forwarding_rule" "udp500" {
#   name        = "europe-vpn-udp500"
#   region      = var.config.region
#   ip_protocol = "UDP"
#   ip_address  = google_compute_address.europe_vpn_ip.address
#   port_range  = "500"
#   target      = google_compute_vpn_gateway.europe_vpn_gateway.self_link
# }

# resource "google_compute_forwarding_rule" "udp4500" {
#   name        = "europe-vpn-udp4500"
#   region      = var.config.region
#   ip_protocol = "UDP"
#   ip_address  = google_compute_address.europe_vpn_ip.address
#   port_range  = "4500"
#   target      = google_compute_vpn_gateway.europe_vpn_gateway.self_link
# }

output "europe_vpn_ip_address" {
  value = google_compute_address.europe_vpn_ip.address
}

output "network_id" {
  value = google_compute_network.europe_network.id
}


