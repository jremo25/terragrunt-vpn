variable "asia_network_config" {
  type = object({
    network_name             = string
    auto_create_subnetworks  = bool
    subnet_name              = string
    subnet_cidr              = string
    region                   = string
    private_ip_google_access = bool
    firewall = object({
      name          = string
      ports         = list(string)
      source_ranges = list(string)
      target_tags   = list(string)
    })
  })
}

variable "asia_vm_config" {
  type = object({
    name         = string
    machine_type = string
    zone         = string
    image_family = string
    tags         = list(string)
  })
}

variable "peer_ip" {
  type = string
}

variable "local_traffic_selector" {
  type = list(string)
}

variable "remote_traffic_selector" {
  type = list(string)
}
