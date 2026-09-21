output "workspace" {
  description = "Active Terraform workspace"
  value       = terraform.workspace
}

output "vpc_id" {
  description = "Default VPC used"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "Subnets discovered inside the default VPC"
  value       = data.aws_subnets.default.ids
}

output "ami_id" {
  description = "Resolved AMI used for the instances"
  value       = data.aws_ami.amazon_linux.id
}

output "instance_ids" {
  description = "IDs of all launched instances"
  value       = aws_instance.app[*].id
}

output "instance_public_ips" {
  description = "Public IPs of the launched instances"
  value       = aws_instance.app[*].public_ip
}

output "dashboard_urls" {
  description = "URLs for the live environment dashboard"
  value       = [for ip in aws_instance.app[*].public_ip : "http://${ip}"]
}

output "instance_type" {
  description = "EC2 instance type"
  value       = var.instance_type
}

output "instance_count" {
  description = "Number of EC2 instances"
  value       = var.instance_count
}
output "security_group_id" {
  description = "Security group attached to the EC2 instances"
  value       = aws_security_group.app.id
}