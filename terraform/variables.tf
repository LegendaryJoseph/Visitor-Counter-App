variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.nano"
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
  default     = "ami-008363bb6918a3baa"
}


variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into the instance"
  type        = string
  default     = "41.209.14.77/32"
}


variable "github_repo" {
  description = "HTTPS clone URL for the repo that contains Dockerfile and docker-compose.yml"
  type        = string
  default     = "https://github.com/LegendaryJoseph/Visitor-Counter-App.git"
}