
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

#########################
# Network + Subnet
#########################

resource "google_compute_network" "gke_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_cidr_range
  region        = var.region
  network       = google_compute_network.gke_vpc.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = var.secondary_range_pods
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.secondary_range_services
  }
}

#########################
# GKE Cluster (Private, VPC-native)
#########################

resource "google_container_cluster" "private_cluster" {
  name     = var.cluster_name
  location = var.region

  # Basic Node Pool Configuration
  remove_default_node_pool = true
  initial_node_count = 1

  # Network configuration
  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28" # Must not overlap existing ranges
    enable_private_endpoint = false           # Keeping API public, restrict with authorized networks if needed
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  addons_config {
    gateway_api_config {
      channel = "CHANNEL_STANDARD"
    }
  }

  min_master_version = var.cluster_version
}

#########################
# Node Pool
#########################

# Create a node pool (since we removed the default one)
resource "google_container_node_pool" "default_pool" {
  name       = "${var.cluster_name}-default-pool"
  location   = var.region
  cluster    = google_container_cluster.private_cluster.name
  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type  # Smallest recommended instance
    disk_size_gb = 20
    preemptible  = true  # Use preemptible nodes for cost-saving
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

terraform {
  backend "gcs" {
    bucket  = "onlineliquorservices_bucket"
    prefix  = "terraform/gke-cluster/tfstate"
  }
}