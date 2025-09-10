variable "project_id" {
  description = "The GCP project ID (same project will host VPC and GKE)."
  type        = string
  default     = "noble-linker-471623-s6"
}

variable "region" {
  description = "Region for resources."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone for resources."
  type        = string
  default     = "us-central1-a"
}

variable "vpc_name" {
  type    = string
  default = "gke-vpc"
}

variable "subnet_name" {
  type    = string
  default = "gke-subnet"
}

variable "subnet_ip_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "secondary_range_pods" {
  type    = string
  default = "10.1.0.0/20"
}

variable "secondary_range_services" {
  type    = string
  default = "10.2.0.0/22"
}

variable "cluster_name" {
  type    = string
  default = "private-gke-cluster"
}

variable "cluster_version" {
  type    = string
  default = "latest"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_machine_type" {
  type    = string
  default = "e2-medium"
}