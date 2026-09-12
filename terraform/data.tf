# Security Group for Managed DBs
resource "aws_security_group" "db_sg" {
  name        = "project-bedrock-db-sg"
  description = "Allow database traffic from EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "project-bedrock-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = local.common_tags
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Catalog Service DB (MySQL)
resource "aws_db_instance" "mysql_catalog" {
  allocated_storage      = 20
  db_name                = "catalog"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro"
  username               = "catalog_user"
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = local.common_tags
}

# Orders Service DB (PostgreSQL)
resource "aws_db_instance" "postgres_orders" {
  allocated_storage      = 20
  db_name                = "orders"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t4g.micro"
  username               = "orders_user"
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = local.common_tags
}

# Carts Service DB (DynamoDB)
resource "aws_dynamodb_table" "carts" {
  name         = "project-bedrock-carts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = local.common_tags
}
