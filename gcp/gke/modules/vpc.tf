module "vpc" {
  source = "terraform-google-modules/network/google"

  project_id                             = var.project_id
  network_name                           = "${var.project_id}-vpc"
  routing_mode                           = "REGIONAL"
  auto_create_subnetworks                = false
  mtu                                    = 1460
  delete_default_internet_gateway_routes = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]

  subnets = [
    {
      subnet_name               = "private-subnet"
      subnet_ip                 = "10.0.0.0/18"
      subnet_region             = var.region
      subnet_private_access     = "true"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
    }
  ]

  secondary_ranges = {
    private-subnet = [
      {
        range_name    = "k8s-pod-range"
        ip_cidr_range = "10.48.0.0/14"
      },
      {
        range_name    = "k8s-service-range"
        ip_cidr_range = "10.52.0.0/20"
      }
    ]
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}