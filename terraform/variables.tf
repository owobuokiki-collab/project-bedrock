variable "aws_region" {
  description = "AWS region for Project Bedrock"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "project-bedrock-cluster"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "project-bedrock-vpc"
}

variable "namespace" {
  description = "Kubernetes application namespace"
  type        = string
  default     = "retail-app"
}

variable "developer_username" {
  description = "Developer IAM username"
  type        = string
  default     = "bedrock-dev-view"
}

variable "student_id" {
  description = "Student ID used for globally unique S3 bucket name"
  type        = string
}

variable "alert_email" {
  description = "Email address for AWS Budget notifications"
  type        = string
}
