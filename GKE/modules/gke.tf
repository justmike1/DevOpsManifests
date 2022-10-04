module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_id
  name                       = var.cluster_name
  remove_default_node_pool   = true
  region                     = var.region
  zones                      = ["${var.region}-a", "${var.region}-b", "${var.region}-f"]
  network                    = module.vpc.network_name
  subnetwork                 = "private-subnet"
  ip_range_pods              = "k8s-pod-range"
  ip_range_services          = "k8s-service-range"
  identity_namespace         = "${var.project_id}.svc.id.goog"
  kubernetes_version         = "1.22"
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  release_channel            = "REGULAR"
  filestore_csi_driver       = false

  node_pools = [
    {
      name               = "master"
      machine_type       = var.machine_type
      min_count          = 1
      max_count          = 10
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.kubernetes.email
      preemptible        = false
      initial_node_count = 1
    },
    {
      name               = "workers"
      machine_type       = var.machine_type
      min_count          = 0
      max_count          = 10
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.kubernetes.email
      preemptible        = true
      initial_node_count = 0
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite"
    ]
  }

  node_pools_labels = {
    all = {}

    master = {
      role = "general"
    }

    workers = {
      role = "worker"
      team = "devops"
    }
  }

  node_pools_metadata = {
    all = {}
  }

  node_pools_taints = {
    all = [{
      key    = "node.cilium.io/agent-not-ready"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    workers = [{
      key    = "instance_type"
      value  = "spot"
      effect = "NO_SCHEDULE"
    }]
  }

  node_pools_tags = {
    all = []

    master = [
      "master",
    ]
    workers = [
      "workers",
    ]
  }
}
