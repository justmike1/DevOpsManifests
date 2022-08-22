resource "aws_elasticache_cluster" "redis-tmp" {
  cluster_id           = "redis-tmp"
  engine               = "redis"
  node_type            = "cache.${var.instance_type}"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
}
resource "aws_elasticache_subnet_group" "redis-tmp" {
  name       = "redis-tmp-subnet"
  subnet_ids = [vpc.private_subnets[0]]
}