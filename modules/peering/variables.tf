variable "peering_config" {
  type = object({
    america_network_id = string
    europe_network_id  = string
  })
}