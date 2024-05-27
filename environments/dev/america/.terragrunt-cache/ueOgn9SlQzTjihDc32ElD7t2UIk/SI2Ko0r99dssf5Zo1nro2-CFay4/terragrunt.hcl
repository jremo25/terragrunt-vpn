include {
  path = find_in_parent_folders()
}

terraform {
  source = "file://C:/Users/jdarr/Downloads/terragrunt-vpn/modules/america"
}

inputs = {
  project = "inner-replica-417201"

  americas_network_config = {
    network_name        = "americas-network"
    auto_create_subnets = false
    subnet_configs = {
      "americas-subnet1" = {
        name              = "americas-subnet1"
        cidr              = "172.16.20.0/24"
        region            = "us-west1"
        private_ip_access = true
      },
      "americas-subnet2" = {
        name              = "americas-subnet2"
        cidr              = "172.16.21.0/24"
        region            = "us-east1"
        private_ip_access = true
      }
    }
    vm_details = [
      {
        name         = "america-vm1"
        machine_type = "e2-medium"
        zone         = "us-west1-a"
        image_family = "projects/debian-cloud/global/images/family/debian-11"
        subnet_name  = "americas-subnet1"
        tags         = ["america-http-server", "iap-ssh-allowed"]
      },
      {
        name         = "america-vm2"
        machine_type = "n2-standard-4"
        zone         = "us-east1-b"
        image_family = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
        subnet_name  = "americas-subnet2"
        tags         = ["america-http-server"]
      }
    ]
    firewall = {
      name            = "america-to-europe-http"
      protocols_ports = {
        tcp = ["80", "22", "3389"]
      }
      source_ranges   = ["0.0.0.0/0", "35.235.240.0/20"]
      target_tags     = ["america-http-server", "iap-ssh-allowed"]
    }
  }
}
