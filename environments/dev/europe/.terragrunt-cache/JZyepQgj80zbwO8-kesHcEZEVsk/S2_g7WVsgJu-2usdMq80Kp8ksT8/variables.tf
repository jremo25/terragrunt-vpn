variable "config" {
  type = object({
    region         = string
    zone           = string
    network_name   = string
    subnet_name    = string
    subnet_cidr    = string
    vm_name        = string
    image_family   = string
    ip_cidr_ranges = list(string)
    allowed_ports  = list(string)
    tags           = list(string)
  })
}

############
variable "peer_ip" {
  type = string
}

variable "local_traffic_selector" {
  type = list(string)
}

variable "remote_traffic_selector" {
  type = list(string)
}
