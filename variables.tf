variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ami_name_filter" {
  description = "AMI name filter"
  type        = string
}