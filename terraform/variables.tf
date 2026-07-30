variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2023)"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2023 - us-east-1
}

variable "db_instance_type" {
  description = "Instance type for database server"
  type        = string
  default     = "t3.small" # 2 vCPU, 2 GB RAM
}

variable "web_instance_type" {
  description = "Instance type for web servers"
  type        = string
  default     = "t3.micro" # 2 vCPU, 1 GB RAM
}

variable "min_web_instances" {
  description = "Minimum number of web server instances"
  type        = number
  default     = 2
}

variable "max_web_instances" {
  description = "Maximum number of web server instances"
  type        = number
  default     = 4
}

variable "desired_web_instances" {
  description = "Desired number of web server instances"
  type        = number
  default     = 2
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "your_ip_cidr" {
  description = "Your IP address in CIDR notation (for bastion access)"
  type        = string
  default     = "0.0.0.0/0" # CHANGE THIS to your IP for security
}
