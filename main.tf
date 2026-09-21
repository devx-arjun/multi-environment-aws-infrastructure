data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  environment = terraform.workspace

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

resource "terraform_data" "workspace_guard" {
  lifecycle {
    precondition {
      condition     = terraform.workspace == var.environment
      error_message = "Workspace and environment must match."
    }
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-${local.environment}-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${local.environment}-sg"
  })
}

resource "aws_instance" "app" {
  count = var.instance_count

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = element(
    data.aws_subnets.default.ids,
    count.index % length(data.aws_subnets.default.ids)
  )

  vpc_security_group_ids = [aws_security_group.app.id]

  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    html = templatefile("${path.module}/templates/index.html.tpl", {
      project_name   = var.project_name
      environment    = local.environment
      instance_type  = var.instance_type
      instance_index = count.index + 1
      instance_count = var.instance_count
      aws_region     = var.aws_region
      availability_zone = data.aws_subnet.selected[
        element(
          data.aws_subnets.default.ids,
          count.index % length(data.aws_subnets.default.ids)
        )
      ].availability_zone
    })
  })

  user_data_replace_on_change = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${local.environment}-${count.index + 1}"
  })

  depends_on = [terraform_data.workspace_guard]
}