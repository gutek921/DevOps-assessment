module "psa" {
  source  = "terraform-google-modules/sql-db/google//modules/private_service_access"
  version = "~> 25.0"

  project_id  = var.project_id
  vpc_network = module.network.network_self_link

  # Let Google allocate a free /16 for peering
  prefix_length = 16
}
