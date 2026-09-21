output "environment" {
  description = "Current Terraform environment"
  value       = var.environment
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_count" {
  description = "Number of EC2 instances"
  value       = var.instance_count
}

output "instance_type" {
  description = "EC2 instance type"
  value       = var.instance_type
}

output "vpc_id" {
  description = "Discovered VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "Discovered subnet IDs"
  value       = data.aws_subnets.default.ids
}

output "availability_zones" {
  description = "Available Availability Zones"
  value       = data.aws_availability_zones.available.names
}

output "ami_id" {
  description = "Selected Amazon Linux AMI"
  value       = data.aws_ami.amazon_linux.id
}