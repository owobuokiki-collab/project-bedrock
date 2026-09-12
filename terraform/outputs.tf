output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = var.cluster_name
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "S3 assets bucket name"
  value       = aws_s3_bucket.assets.id
}

output "catalog_db_endpoint" {
  description = "MySQL DB endpoint for Catalog service"
  value       = aws_db_instance.mysql_catalog.endpoint
}

output "orders_db_endpoint" {
  description = "PostgreSQL DB endpoint for Orders service"
  value       = aws_db_instance.postgres_orders.endpoint
}

output "carts_table_name" {
  description = "DynamoDB table name for Carts service"
  value       = aws_dynamodb_table.carts.name
}


