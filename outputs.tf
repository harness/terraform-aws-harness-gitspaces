locals {
  instance_yaml_instance = terraform.workspace != "default" ? {
    limit = 1000
    name  = "${local.name}-${var.region}"
    type  = "amazon"
    pool  = 0
    platform = {
      os   = "linux"
      arch = "amd64"
    }
    spec = {
      account = {
        region = var.region
      }
      ami       = "ubuntu"
      hibernate = false
      vpc       = module.infra[0].vpc_network_id
      network = {
        security_groups = [module.infra[0].aws_security_group_id]
        private_ip      = true
      }
      zone_details   = module.infra[0].private_subnet_ids
      device_name    = "/dev/sda1"
      market_type    = "on-demand"
      root_directory = "/"
      user           = "ubuntu"
    }
  } : null
}

resource "null_resource" "upsert_yaml" {
  count = terraform.workspace != "default" ? 1 : 0

  triggers = {
    always_run = terraform.workspace != "default" ? timestamp() : "skip"
  }

  provisioner "local-exec" {
    command = <<EOT
tmpfile=$(mktemp)
echo '${yamlencode(local.instance_yaml_instance)}' > "$${tmpfile}"
chmod 600 "$${tmpfile}"
${path.module}/scripts/upsert_pool_yaml.sh "${local.name}-${var.region}" "$${tmpfile}"
rm -f "$${tmpfile}"
EOT
  }
}

resource "null_resource" "delete_yaml" {
  count = terraform.workspace == "default" ? 1 : 0

  triggers = {
    always_run = terraform.workspace == "default" ? timestamp() : "skip"
  }

  provisioner "local-exec" {
    command = <<EOT
${path.module}/scripts/delete_pool_yaml.sh
EOT
  }
}
