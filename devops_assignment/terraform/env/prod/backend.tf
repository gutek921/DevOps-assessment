terraform {
  backend "gcs" {
    bucket = "tfstate-yourcompany-prod" # need to be created
    prefix = "gke-webapp/prod"
  }
}