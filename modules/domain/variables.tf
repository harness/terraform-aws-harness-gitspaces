variable "infra_config_yaml_file" {
  description = "The path to the YAML file containing infrastructure configuration."
  type        = string
}

variable "use_certificate_manager" {
  description = "Use AWS Certificate Manager for SSL certificates."
  type        = bool
  default     = true
}

variable "region" {
  description = "The AWS region."
  type        = string
}