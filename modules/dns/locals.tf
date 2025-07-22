locals {
  infra_config   = yamldecode(file(var.infra_config_yaml_file))
  name           = local.infra_config.name
  domain         = local.infra_config.domain
  region_configs = local.infra_config.region_configs
}