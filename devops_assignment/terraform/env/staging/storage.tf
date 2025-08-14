module "static_bucket" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 11.0"

  project_id = var.project_id
  names      = [var.static_bucket_name]
  location   = var.region
  prefix     = "my-unique-prefix-like-company-name"

  set_admin_roles = true
  admins          = ["group:devops-admins@awesome.com"]

  versioning               = { (var.static_bucket_name) = true }
  force_destroy            = { (var.static_bucket_name) = true }
  public_access_prevention = { (var.static_bucket_name) = "enforced" }

  bucket_admins = {
    (var.static_bucket_name) = "serviceAccount:${google_service_account.app_gsa.email}"
  }

  labels = {
    terraform   = "true"
    gcs         = "true"
    gke_usage   = "true"
    environment = var.environment
  }
}