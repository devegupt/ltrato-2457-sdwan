terraform {
  backend "http" {
    skip_cert_verification = true
  }
}

module "sdwan" {
  source  = "netascode/nac-sdwan/sdwan"
  version = "1.5.0"

  yaml_directories = ["data/"]

  write_default_values_file = "defaults.yaml"
}
