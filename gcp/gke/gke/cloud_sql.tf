locals {
  read_replica_ip_configuration = {
    ipv4_enabled        = false
    require_ssl         = false
    private_network     = "projects/${var.project_id}/global/networks/${module.vpc.network_name}"
    allocated_ip_range  = null
    authorized_networks = []
  }
}

module "sql-db" {
  source            = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  name              = "${var.cluster_name}-sql"
  project_id        = var.project_id
  database_version  = "POSTGRES_14"
  enable_default_db = false

  // Master configurations
  tier                            = var.sql_tier
  region                          = var.sql_region
  disk_size                       = var.sql_disk_size
  disk_type                       = "PD_SSD"
  zone                            = "${var.region}-c"
  availability_type               = "REGIONAL"
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"

  deletion_protection = false

  database_flags = [{ name = "autovacuum", value = "off" }]

  user_labels = {
    environment = var.environment
  }

  ip_configuration = {
    ipv4_enabled        = false
    require_ssl         = false
    private_network     = "projects/${var.project_id}/global/networks/${module.vpc.network_name}"
    allocated_ip_range  = null
    authorized_networks = []
  }

  backup_configuration = {
    enabled                        = true
    start_time                     = "02:00"
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = 365
    retention_unit                 = "COUNT"
  }

  // Read replica configurations
  read_replica_name_suffix = "-read-"
  read_replicas = [
    {
      name                  = "0"
      zone                  = "${var.region}-a"
      availability_type     = "REGIONAL"
      tier                  = var.sql_tier
      ip_configuration      = local.read_replica_ip_configuration
      database_flags        = [{ name = "autovacuum", value = "off" }]
      disk_autoresize       = null
      disk_autoresize_limit = null
      disk_size             = null
      disk_type             = "PD_HDD"
      user_labels           = { replica = "0" }
      encryption_key_name   = null
    },
    {
      name                  = "1"
      zone                  = "${var.region}-b"
      availability_type     = "REGIONAL"
      tier                  = var.sql_tier
      ip_configuration      = local.read_replica_ip_configuration
      database_flags        = [{ name = "autovacuum", value = "off" }]
      disk_autoresize       = null
      disk_autoresize_limit = null
      disk_size             = null
      disk_type             = "PD_HDD"
      user_labels           = { replica = "1" }
      encryption_key_name   = null
    },
  ]

  additional_databases = [for db in var.sql_databases : {
    name      = db
    charset   = "UTF8"
    collation = "en_US.UTF8"
  }]

  depends_on = [
    google_project_service.networking-service,
    module.vpc,
    google_service_networking_connection.private_vpc_connection,
    google_compute_global_address.private_ip_address
  ]
}
