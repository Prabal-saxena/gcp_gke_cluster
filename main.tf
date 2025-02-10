
provider "google" {
  project = "spheric-base-448422-q9"
  region  = "us-central1"
}

resource "google_container_cluster" "gke_cluster" {
  name     = "liquor-gke-cluster"
  location = "us-central1"

  # Basic Node Pool Configuration
  remove_default_node_pool = true
  initial_node_count = 1

  # Network configuration
  networking_mode = "VPC_NATIVE"
}

# Create a node pool (since we removed the default one)
resource "google_container_node_pool" "node_pool" {
  name       = "gke-node"
  cluster    = google_container_cluster.gke_cluster.id
  location   = google_container_cluster.gke_cluster.location

  node_count = 1  # Minimum one node

  node_config {
    machine_type = "e2-medium"  # Smallest recommended instance
    disk_size_gb = 20
    preemptible  = true  # Use preemptible nodes for cost-saving
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

terraform {
  backend "gcs" {
    bucket  = "onlineliquorservices_bucket"
    prefix  = "terraform/gke-cluster/tfstate"
  }
}