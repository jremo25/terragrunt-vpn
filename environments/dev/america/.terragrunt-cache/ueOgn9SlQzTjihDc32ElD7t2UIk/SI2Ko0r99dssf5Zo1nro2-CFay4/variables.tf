variable "americas_network_config" {
  type = object({
    network_name        = string
    auto_create_subnets = bool
    subnet_configs = map(object({
      name              = string
      cidr              = string
      region            = string
      private_ip_access = bool
    }))
    vm_details = list(object({
      name         = string
      machine_type = string
      zone         = string
      image_family = string
      subnet_name  = string
      tags         = list(string)
    }))
    firewall = object({
      name            = string
      protocols_ports = map(list(string))
      source_ranges   = list(string)
      target_tags     = list(string)
    })
  })
}
