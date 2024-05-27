include {
  path = find_in_parent_folders()
}

dependency "america" {
  config_path = "../america"
}


terraform {
  source = "file://C:/Users/jdarr/Downloads/terragrunt-vpn/modules/europe"
}

inputs = {
  project = "inner-replica-417201"

  config = {
    region         = "europe-west1"
    zone           = "europe-west1-b"
    network_name   = "europe-network"
    subnet_name    = "europe-subnet"
    subnet_cidr    = "10.150.11.0/24"
    vm_name        = "europe-vm"
    image_family   = "projects/debian-cloud/global/images/family/debian-11"
    ip_cidr_ranges = ["10.150.11.0/24", "172.16.20.0/24", "172.16.21.0/24", "192.168.11.0/24"]
    allowed_ports  = ["80"]
    tags           = ["europe-http-server"]
  }

  peer_ip                 = "34.84.169.158"
  local_traffic_selector  = ["10.150.11.0/24"]
  remote_traffic_selector = ["192.168.11.0/24"]
}
