terraform {
  backend "gcs" {
    bucket = "tfstate-yourcompany-staging" # need to be created
    prefix = "gke-webapp/staging"
  }
}