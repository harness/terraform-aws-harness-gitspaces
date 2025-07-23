variable "infra_config_yaml_file" {
  description = "The path to the YAML file containing infrastructure configuration."
  type        = string
}

variable "use_certificate_manager" {
  description = "Use AWS Certificate Manager for SSL certificates."
  type        = bool
  default     = true
}

variable "manage_dns_zone" {
  description = "Manage DNS zone."
  type        = bool
  default     = true
}

variable "private_key_path" {
  description = "Path to the private key file for SSL certificate."
  type        = string
  default     = ""
}

variable "certificate_path" {
  description = "Path to the SSL certificate file."
  type        = string
  default     = ""
}

variable "chain_path" {
  description = "Path to the SSL certificate file."
  type        = string
  default     = ""
}

variable "region" {
  description = "The AWS region."
  type        = string
}