include {
  path = find_in_parent_folders()
}

# dependency "europe" {
#   config_path = "../europe"
# }

terraform {
  source = "file://C:/Users/jdarr/Downloads/terragrunt-vpn/modules/asia"
}

inputs = {
  asia_network_config = {
    network_name             = "asia-network"
    auto_create_subnetworks  = false
    subnet_name              = "asia-subnet"
    subnet_cidr              = "192.168.11.0/24"
    region                   = "asia-northeast1"
    private_ip_google_access = true
    firewall = {
      name          = "asia-allow-rdp"
      ports         = ["3389"]
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["asia-rdp-server"]
    }
  }

  asia_vm_config = {
    name         = "asia-vm"
    machine_type = "n2-standard-4"
    zone         = "asia-northeast1-c"
    image_family = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
    tags         = ["asia-rdp-server"]
  }

  peer_ip                 = null
  local_traffic_selector  = ["192.168.11.0/24"]
  remote_traffic_selector = ["10.150.11.0/24"]
}


