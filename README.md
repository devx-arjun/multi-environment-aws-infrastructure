# Terraform Multi-Environment Challenge

A multi-environment AWS infrastructure project using **one Terraform codebase** to manage two isolated environments:

* `dev`
* `prod`

The project demonstrates **Terraform workspaces**, **environment-specific variables**, **AWS data sources**, reusable infrastructure, and a small live frontend dashboard.

---

## Architecture

```text
                    Terraform Codebase
                           │
                ┌──────────┴──────────┐
                │                     │
             dev workspace        prod workspace
                │                     │
          terraform.tfvars.dev   terraform.tfvars.prod
                │                     │
             1 × t3.micro          3 × t3.small
                │                     │
                └──────────┬──────────┘
                           │
                      AWS Default VPC
                           │
                    Security Group
                           │
                     EC2 Instances
                           │
                        Nginx
                           │
                    Live Dashboard
```

The same `main.tf` is reused for both environments. Only the workspace and variable values change.

---

## Project Structure

```text
terraform-multi-env/
│
├── .terraform/                  # Terraform working directory
├── terraform.tfstate.d/         # Workspace-specific local state
│
├── templates/
│   ├── index.html.tpl            # Frontend dashboard template
│   └── user_data.sh.tpl          # EC2 startup script
│
├── main.tf                       # AWS resources and data sources
├── variables.tf                  # Input variables
├── outputs.tf                    # Useful deployment outputs
├── terraform.tf                  # Terraform and AWS provider configuration
│
├── terraform.tfvars.dev          # Development configuration
├── terraform.tfvars.prod         # Production configuration
│
├── .terraform.lock.hcl           # Provider dependency lock file
├── .gitignore                    # Git exclusions
└── README.md                     # Project documentation
```

---

# Phase 1 — Setup

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Create the two workspaces:

```bash
terraform workspace new dev
terraform workspace new prod
```

Check the available workspaces:

```bash
terraform workspace list
```

Expected:

```text
* dev
  prod
```

---

# Phase 2 — Variables

The project uses six input variables:

| Variable          | Purpose                                 |
| ----------------- | --------------------------------------- |
| `aws_region`      | AWS deployment region                   |
| `project_name`    | Name used for the project and resources |
| `environment`     | Environment name (`dev` or `prod`)      |
| `instance_type`   | EC2 instance type                       |
| `instance_count`  | Number of EC2 instances                 |
| `ami_name_filter` | Amazon Linux AMI name filter            |

The `environment` variable includes validation so only `dev` or `prod` can be used.

The instance count is also validated to ensure a reasonable value.

---

# Environment Configuration

## Development

`terraform.tfvars.dev`

```hcl
aws_region      = "ap-south-1"
project_name    = "multi-env-demo"
environment     = "dev"
instance_type   = "t3.micro"
instance_count  = 1
ami_name_filter = "al2023-ami-*-x86_64"
```

Development uses a smaller configuration:

```text
1 × t3.micro
```

---

## Production

`terraform.tfvars.prod`

```hcl
aws_region      = "ap-south-1"
project_name    = "multi-env-demo"
environment     = "prod"
instance_type   = "t3.small"
instance_count  = 3
ami_name_filter = "al2023-ami-*-x86_64"
```

Production uses:

```text
3 × t3.small
```

This demonstrates how the same Terraform code can create different infrastructure based on environment-specific variables.

---

# Phase 3 — AWS Data Sources

The project does not hardcode VPC, subnet, or AMI IDs.

It dynamically discovers AWS resources using four data sources:

1. `aws_vpc.default`
2. `aws_subnets.default`
3. `aws_subnet.selected`
4. `aws_ami.amazon_linux`

### VPC

Terraform discovers the default VPC:

```hcl
data "aws_vpc" "default" {
  default = true
}
```

### Subnets

Terraform discovers the subnets belonging to that VPC:

```hcl
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
```

### Individual Subnet Details

The project uses `for_each` to discover details such as the Availability Zone of each subnet.

### Amazon Linux AMI

The latest matching Amazon Linux 2023 AMI is discovered dynamically instead of hardcoding an AMI ID.

This makes the configuration more reusable across deployments.

---

# Workspace Guard

The project includes a Terraform workspace guard:

```hcl
resource "terraform_data" "workspace_guard" {
  lifecycle {
    precondition {
      condition     = terraform.workspace == var.environment
      error_message = "Workspace and environment must match."
    }
  }
}
```

This prevents accidentally deploying production variables while the `dev` workspace is selected.

For example:

```text
Workspace:   dev
Environment: prod
```

will fail the Terraform precondition.

The expected configuration is:

```text
dev workspace  → terraform.tfvars.dev
prod workspace → terraform.tfvars.prod
```

---

# Phase 4 — Deploy

## Development

Select the development workspace:

```bash
terraform workspace select dev
```

Verify:

```bash
terraform workspace show
```

Plan:

```bash
terraform plan -var-file="terraform.tfvars.dev"
```

Apply:

```bash
terraform apply -var-file="terraform.tfvars.dev"
```

Expected infrastructure:

```text
1 × t3.micro
```

---

## Production

Switch to production:

```bash
terraform workspace select prod
```

Verify:

```bash
terraform workspace show
```

Plan:

```bash
terraform plan -var-file="terraform.tfvars.prod"
```

Apply:

```bash
terraform apply -var-file="terraform.tfvars.prod"
```

Expected infrastructure:

```text
3 × t3.small
```

---

# Live Frontend Dashboard

Each EC2 instance automatically installs Nginx using `user_data`.

The startup process is:

```text
EC2 starts
   ↓
user_data executes
   ↓
Nginx installed
   ↓
HTML dashboard generated
   ↓
Nginx serves dashboard
```

The dashboard displays:

* Environment
* Project name
* Instance number
* Total instance count
* Instance type
* Availability Zone
* AWS region
* Deployment method

The dashboard uses a different visual badge for `dev` and `prod`.

After deployment, retrieve the dashboard URLs:

```bash
terraform output dashboard_urls
```

Example:

```text
[
  "http://13.232.28.250",
  "http://65.1.145.253",
  "http://13.201.185.189"
]
```

Open any URL in a browser to view the live dashboard.

This provides a visual demonstration that the infrastructure is actually running rather than relying only on Terraform plan output.

---

# Outputs

The project provides several useful outputs:

```bash
terraform output
```

Available outputs include:

| Output                | Purpose                      |
| --------------------- | ---------------------------- |
| `workspace`           | Current Terraform workspace  |
| `vpc_id`              | Default VPC ID               |
| `subnet_ids`          | Discovered subnet IDs        |
| `ami_id`              | Resolved Amazon Linux AMI    |
| `instance_ids`        | EC2 instance IDs             |
| `instance_public_ips` | Public IP addresses          |
| `dashboard_urls`      | URLs for the live dashboards |
| `instance_type`       | EC2 instance type            |
| `instance_count`      | Number of instances          |

For example:

```bash
terraform output instance_public_ips
```

or:

```bash
terraform output dashboard_urls
```

---

# Phase 5 — Verify

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Check workspaces:

```bash
terraform workspace list
```

Check the current workspace:

```bash
terraform workspace show
```

Check the data blocks:

```bash
grep -c "^data " main.tf
```

Expected:

```text
4
```

On PowerShell, you can use:

```powershell
Select-String -Path .\main.tf -Pattern '^data '
```

Review the development plan:

```bash
terraform plan -var-file="terraform.tfvars.dev"
```

Review the production plan:

```bash
terraform plan -var-file="terraform.tfvars.prod"
```

Check dashboard URLs:

```bash
terraform output dashboard_urls
```

---

# Environment Comparison

| Setting              | Dev        | Prod       |
| -------------------- | ---------- | ---------- |
| Workspace            | `dev`      | `prod`     |
| Instance type        | `t3.micro` | `t3.small` |
| Instance count       | `1`        | `3`        |
| Environment variable | `dev`      | `prod`     |
| Dashboard            | Live       | Live       |

The important point is that **the Terraform code is the same**. The environment-specific `.tfvars` files control the differences.

---

# Resource Tagging

Resources are tagged using common Terraform tags:

```text
Project
Environment
ManagedBy
```

Resources also receive environment-specific names.

Example:

```text
Project     = multi-env-demo
Environment = dev
ManagedBy   = Terraform
```

This makes resources easier to identify and manage in AWS.

---

# Terraform State and Workspaces

Terraform workspaces provide separate state for the environments.

The project uses the default local backend.

Workspace-specific state is stored under:

```text
terraform.tfstate.d/
```

The important concept is:

```text
dev workspace  → dev state
prod workspace → prod state
```

This allows both environments to use the same Terraform configuration while maintaining separate state.

---

# Cleanup

AWS resources should be destroyed after testing to avoid unnecessary charges.

Destroy development:

```bash
terraform workspace select dev
terraform destroy -var-file="terraform.tfvars.dev"
```

Destroy production:

```bash
terraform workspace select prod
terraform destroy -var-file="terraform.tfvars.prod"
```

---

# Project Checklist

* [x] Two Terraform workspaces: `dev` and `prod`
* [x] Separate workspace state
* [x] Six Terraform input variables
* [x] Environment-specific `.tfvars` files
* [x] Different dev and prod infrastructure configurations
* [x] Four AWS data sources
* [x] No hardcoded VPC/subnet/AMI IDs
* [x] Dev uses `t3.micro`
* [x] Prod uses `t3.small`
* [x] Dev creates 1 instance
* [x] Prod creates 3 instances
* [x] Resources tagged with environment information
* [x] Workspace/environment guard
* [x] Nginx frontend dashboard
* [x] Terraform outputs for verification
* [x] `terraform validate` passes
* [x] `terraform fmt` applied
* [x] Dev and prod deployment flow tested

---

# Key Concepts Demonstrated

This project demonstrates practical use of:

* Terraform Workspaces
* Terraform Variables
* Variable validation
* Environment-specific `.tfvars`
* Terraform Data Sources
* AWS Provider
* EC2
* Security Groups
* Dynamic AMI discovery
* Dynamic subnet discovery
* Terraform `count`
* Terraform `for_each`
* Terraform `templatefile`
* Terraform lifecycle preconditions
* Resource tagging
* Terraform outputs
* EC2 `user_data`
* Nginx
* Basic infrastructure verification

The main goal is to demonstrate how a **single reusable Terraform configuration** can manage multiple AWS environments with isolated state and environment-specific infrastructure.
