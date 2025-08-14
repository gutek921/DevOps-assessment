locals {
  env_name        = basename(path.cwd)
  vpc_name        = "${local.env_name}-vpc"
  subnet_name     = "${local.env_name}-subnet"
  pods_range_name = "${local.env_name}-pods"
  svc_range_name  = "${local.env_name}-services"
}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 11.0"

  project_id   = var.project_id
  network_name = local.vpc_name
  routing_mode = "GLOBAL"

  subnets = [{
    subnet_name           = local.subnet_name
    subnet_ip             = var.subnet_cidr
    subnet_region         = var.region
    subnet_private_access = true
    secondary_ip_range = [
      { range_name = local.pods_range_name, ip_cidr_range = "10.100.0.0/14" },
      { range_name = local.svc_range_name, ip_cidr_range = "10.104.0.0/20" }
    ]
  }]
}

module "nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "~> 5.3"

  project_id    = var.project_id
  region        = var.region
  router        = "${local.env_name}-router"
  network       = module.network.network_name
  create_router = true
}
