module "sql" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 25.0"

  project_id       = var.project_id
  region           = var.region
  name             = "pg-ha"
  database_version = var.db_version
  tier             = var.db_tier

  availability_type               = "REGIONAL"
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"

  ip_configuration = {
    ipv4_enabled    = false
    private_network = module.network.network_self_link
    require_ssl     = false
  }

  deletion_protection = true

  backup_configuration = {
    enabled                        = true
    start_time                     = "21:00"
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = 7
    retention_unit                 = "COUNT"
  }

  db_name       = var.db_name
  user_name     = var.db_user
  user_password = var.db_password != "" ? var.db_password : null

  user_labels = {
    terraform   = "true"
    database    = "true"
    environment = var.environment
  }
}
