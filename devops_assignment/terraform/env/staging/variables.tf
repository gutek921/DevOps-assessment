variable "project_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "region" {
  type    = string
  default = "europe-central2"
}

# primary subnet CIDR for nodes (secondary ranges for pods/services set in network.tf)
variable "subnet_cidr" {
  type    = string
  default = "10.41.0.0/20"
}

variable "static_bucket_name" {
  type = string
}

variable "static_public_read" {
  type    = bool
  default = true
}

variable "db_version" {
  type    = string
  default = "POSTGRES_17"
}

variable "db_tier" {
  type    = string
  default = "db-custom-1-3840"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_user" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "domain" {
  type    = string
  default = ""
}

variable "enable_https" {
  type    = bool
  default = true
}

variable "enable_cdn" {
  type    = bool
  default = true
}

variable "notification_channels" {
  type        = list(string)
  default     = []
  description = "List of Monitoring Notification Channel IDs"
}
