locals {
  is_global = terraform.workspace == "default"
  region    = terraform.workspace
}

provider "aws" {
  region     = var.region != "default" ? var.region : var.default_region
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.token
}

module "infra" {
  count                   = local.is_global == false ? 1 : 0
  source                  = "./modules/infra"
  infra_config_yaml_file  = var.infra_config_yaml_file
  use_certificate_manager = var.use_certificate_manager
  private_key_path        = var.private_key_path
  certificate_path        = var.certificate_path
  region                  = var.region
  manage_dns_zone         = var.manage_dns_zone
  depends_on              = [module.domain]
}

module "dns" {
  count                  = var.manage_dns_zone && local.is_global ? 1 : 0
  source                 = "./modules/dns"
  infra_config_yaml_file = var.infra_config_yaml_file
}

module "iam" {
  count                  = local.is_global ? 1 : 0
  source                 = "./modules/iam"
  infra_config_yaml_file = var.infra_config_yaml_file
}

module "domain" {
  count                   = var.manage_dns_zone && local.is_global == false ? 1 : 0
  source                  = "./modules/domain"
  infra_config_yaml_file  = var.infra_config_yaml_file
  use_certificate_manager = var.use_certificate_manager
  region                  = var.region
  depends_on              = [module.dns]
}