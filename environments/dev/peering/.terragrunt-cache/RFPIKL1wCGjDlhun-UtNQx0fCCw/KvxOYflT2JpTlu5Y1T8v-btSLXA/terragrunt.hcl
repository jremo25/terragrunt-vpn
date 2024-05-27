include {
  path = find_in_parent_folders()
}

dependency "america" {
  config_path = "../america"
}

dependency "europe" {
  config_path = "../europe"
}

terraform {
  source = "file://C:/Users/jdarr/Downloads/terragrunt-vpn/modules/peering"
}

inputs = {
  project = "inner-replica-417201"

  peering_config = {
    america_network_id = dependency.america.outputs.network_id
    europe_network_id  = dependency.europe.outputs.network_id
  }
}
