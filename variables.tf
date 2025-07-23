variable "default_region" {
  description = "The AWS region used while managing for global resources."
  type        = string
}

variable "access_key" {
  description = "The AWS access key."
  type        = string
}

variable "secret_key" {
  description = "The AWS secret key."
  type        = string
}

variable "token" {
  description = "The AWS session token."
  type        = string
  default     = ""
}

variable "infra_config_yaml_file" {
  description = "The path to the YAML file containing infrastructure configuration."
  type        = string
}

variable "manage_dns_zone" {
  description = "Manage DNS records for the various resources created in this module."
  type        = bool
  default     = true
}

variable "use_certificate_manager" {
  description = "Use AWS Certificate Manager for TLS certificate."
  type        = bool
  default     = true
}

variable "private_key_path" {
  description = "Path to the private key file for TLS certificate."
  type        = string
  default     = ""
}

variable "certificate_path" {
  description = "Path to the TLS certificate file."
  type        = string
  default     = ""
}

variable "chain_path" {
  description = "Path to the TLS certificate file."
  type        = string
  default     = ""
}