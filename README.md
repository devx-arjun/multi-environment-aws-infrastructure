# Terraform Multi-Environment Provisioning

## Objective
Provision isolated Dev and Prod environments using Terraform workspaces.

## Environments

Dev:
- 1 x t3.micro

Prod:
- 3 x t3.small

## Terraform Concepts Used
- AWS provider
- Terraform workspaces
- Variables
- Environment-specific tfvars
- Data sources
- EC2 resources
- Resource tagging

## Data Sources
- Default VPC
- Subnets
- Availability Zones
- Amazon Linux AMI

## Validation

terraform fmt
terraform validate
terraform plan
terraform apply