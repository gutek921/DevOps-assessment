data "google_client_config" "default" {}

data "google_container_cluster" "cluster" {
  project  = var.project_id
  name     = module.gke.name
  location = module.gke.location
}

# For upload manifests
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
}
