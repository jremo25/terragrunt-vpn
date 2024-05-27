remote_state {
  backend = "gcs"
  config = {
    bucket = "statebucket302"
    prefix = "${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  project = "inner-replica-417201"
}

