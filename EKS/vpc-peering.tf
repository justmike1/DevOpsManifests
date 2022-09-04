# resource "aws_vpc_peering_connection" "vpn_peer" {
#   peer_vpc_id = var.peer_vpc_id
#   peer_owner_id = var.peer_owner_id
#   vpc_id      = module.vpc.vpc_id
#   peer_region = var.vpc_peer_region
#   auto_accept = false
# }

# module "pcx-route-vpn" {
#   source            = "rhythmictech/pcx-route-cidr/aws"
#   version           = "1.1.0"
#   route_tables      = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
#   route_table_count = local.number_of_routes
#   destination_cidr  = var.peer_vpc_cidr
#   pcx_id            = aws_vpc_peering_connection.vpn_peer.id
# }
