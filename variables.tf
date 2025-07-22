variable "region" {
  description = "The AWS region."
  type        = string
}

variable "default_region" {
  description = "The default AWS region for global resources."
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
}

variable "infra_config_yaml_file" {
  description = "The path to the YAML file containing infrastructure configuration."
  type        = string
}

variable "manage_dns_zone" {
  type = bool
}

variable "use_certificate_manager" {
  description = "Use AWS Certificate Manager for SSL certificates."
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