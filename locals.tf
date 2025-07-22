locals {
  infra_config = yamldecode(file(var.infra_config_yaml_file))
  name         = local.infra_config.name
}