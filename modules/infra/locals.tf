locals {
  infra_config                     = yamldecode(file(var.infra_config_yaml_file))
  name                             = local.infra_config.name
  account_identifier               = local.infra_config.account_identifier
  infra_provider_config_identifier = local.infra_config.infra_provider_config_identifier
  gateway_secret                   = local.infra_config.gateway.shared_secret
  gateway_version                  = local.infra_config.gateway.version
  cde_manager_url                  = local.infra_config.gateway.cde_manager_url
  gateway_machine_type             = local.infra_config.gateway.instance_type
  gateway_instances                = local.infra_config.gateway.instances
  domain                           = local.infra_config.domain
  vpc_cidr_block                   = local.infra_config.vpc_cidr_block
  region_configs                   = local.infra_config.region_configs
  enable_high_availability         = local.infra_config.gateway.instances > 1 ? true : false
  events_mode                      = local.infra_config.gateway.instances > 1 ? "redis" : "inmemory"
}