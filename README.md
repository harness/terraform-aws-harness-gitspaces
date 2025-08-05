# Harness Gitspaces AWS Infra Module

This Terraform module provisions the core AWS infrastructure required for Harness Gitspaces, including VPC, subnets, security groups, load balancers, gateways, and DNS records.

## Prerequisites

### AWS Permissions

The following permissions must be granted to the user/role whose credentials are provided as input variables in `main.tf`:

#### Custom IAM Permission Set

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:AttachRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:PassRole",
        "iam:List*",
        "iam:Get*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### AWS Managed Policies

1. `AmazonEC2FullAccess`
2. `AmazonElastiCacheFullAccess`
3. `AmazonRoute53FullAccess`
4. `AWSCertificateManagerFullAccess`
5. `ElasticLoadBalancingFullAccess`

### Tools and binaries
The following tools should be present in path.
1. `yq`
2. `jq`

## Inputs

|          Name           | Description                                            | Type   | Default | Required |
|:-----------------------:|--------------------------------------------------------|:-------|:--------|:--------:|
| infra_config_yaml_file  | Path to the YAML file containing infrastructure config | string | n/a     | yes      |
|     default_region      | The AWS region used while managing for global resources | string | n/a     | yes      |
|       access_key        | The AWS access key id                                  | string | n/a     | yes      |
|       secret_key        | The AWS access key secret                              | string | n/a     | yes      |
|          token          | The AWS access session token                           | string   | ""    | no       |
| use_certificate_manager | Use AWS Certificate Manager for TLS certificates       | bool   | true    | no       |
|     manage_dns_zone     | Manage DNS zone for the environment                    | bool   | true   | no       |
|    private_key_path     | Path to private key file for SSL (if not using ACM)    | string | ""      | no       |
|    certificate_path     | Path to SSL certificate file (if not using ACM)        | string | ""      | no       |
|       chain_path        | Path to SSL certificate chain file (if not using ACM)  | string | ""      | no       |


## How to Apply Terraform

### Global resources

First create the resources which will be shared across regions ie Route53 zone and IAM role.
```sh
   terraform workspace select default
   terraform init
   terraform plan
   terraform apply
```
This will create global resources and clear/delete any pool.yaml file present.

**NOTE: Ensure DNS mapping for the domain is present with the SOA before creating regional resources!**

### Region specific resources

To create resources for any region, eg `us-east-1`, create that workspace. 
No need to change the backend once the global resources have been created.
```sh
   terraform workspace select -or-create us-east-1
   terraform init
   terraform plan
   terraform apply
```
This will create regional resources and upsert the region's running config in the pool.yaml file.

## Resources Created

This module provisions and manages:

- **VPC and Subnets**: Custom VPC, public and private subnets across AZs.
- **Security Groups**: For gateways, gitspace instances, and load balancers, with ingress/egress rules for required ports.
- **Load Balancers**: Network Load Balancer (NLB) and Application Load Balancer (ALB) for GitSpaces endpoints.
- **Gateway Autoscaling Groups**: EC2 launch templates and autoscaling groups for gateway instances.
- **NAT Gateways & Internet Gateway**: For outbound internet access from private subnets.
- **Route Tables & Associations**: For public/private subnet routing.
- **DNS Records**: Route53 records for load balancer endpoints (if `manage_dns_zone` is true).
- **SSL/TLS Certificates**: Via ACM or custom files, as configured.
- **Redis**: For high availability of cde-gateway. Only required if number of instances is > 1.


## Example Usage

```hcl
module "harness-gitspaces" {
  source                  = "harness/harness-gitspaces/aws"
  version                 =  0.0.1
  infra_config_yaml_file  = "infra_config.yaml"
  manage_dns_zone         = true
  use_certificate_manager = true
  default_region          = "us-east-1"
  access_key              = "DUMMY"
  secret_key              = "DUMMY"
  token                   = "DUMMY"
}
```


## Outputs
This module outputs a pool.yaml file which contains the configuration required to run the runner component.

### Default workspace
Existing pool.yaml is deleted.

### Non-default workspace
A pool.yaml is created if not present and the region's runner configuration is upserted.
