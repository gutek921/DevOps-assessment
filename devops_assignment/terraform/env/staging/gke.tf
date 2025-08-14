locals {
  env_name        = basename(path.cwd)
  cluster_name    = "${local.env_name}-gke"
  subnet_name     = "${local.env_name}-subnet"
  pods_range_name = "${local.env_name}-pods"
  svc_range_name  = "${local.env_name}-services"
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version = "~> 38.0"

  project_id = var.project_id
  name       = local.cluster_name
  region     = var.region

  network    = module.network.network_name
  subnetwork = local.subnet_name

  # Required for private VPC-native clusters
  ip_range_pods     = local.pods_range_name
  ip_range_services = local.svc_range_name

  enable_private_endpoint = false # don't have vpn to connect so need for now use public endpoint
  enable_cost_allocation  = true

  cluster_resource_labels = {
    terraform   = "true"
    gke         = "true"
    environment = var.environment
  }
}

# SA to access to GCS for files, cache etc.
resource "google_service_account" "app_gsa" {
  account_id   = "gke-app-nginx"
  display_name = "GKE app service account"
}

resource "google_service_account_iam_binding" "wi_binding" {
  service_account_id = google_service_account.app_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[app/web]"
  ]
}

resource "kubernetes_service_account" "app_ksa" {
  metadata {
    name      = "web"
    namespace = "app"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.app_gsa.email
    }
  }
}