resource "aws_elasticache_replication_group" "redis" {
  count                      = local.enable_high_availability ? 1 : 0
  replication_group_id       = "${local.name}-redis"
  description                = "Redis replication group for cde-gateway high availability"
  engine                     = "redis"
  engine_version             = "7.0"
  port                       = 6379
  node_type                  = "cache.t2.small"
  replicas_per_node_group    = 1    # 1 replica = 2 nodes total
  automatic_failover_enabled = true # Needed for multi-AZ
  multi_az_enabled           = true
  parameter_group_name       = "default.redis7"
  subnet_group_name          = aws_elasticache_subnet_group.elasticache_subnet_group.name
  security_group_ids         = [aws_security_group.gateway_sg.id]
  at_rest_encryption_enabled = false
  transit_encryption_enabled = false
  apply_immediately          = true
  tags = {
    Name = "${local.name}-redis"
  }
}

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "${local.name}-subnet-group"
  subnet_ids = values(aws_subnet.private_subnet)[*].id

  tags = {
    Name = "${local.name}-subnet-group"
  }
}
