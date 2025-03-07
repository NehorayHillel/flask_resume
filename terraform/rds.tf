# Retrieve all subnets in the default VPC (used for the DB subnet group)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create a DB subnet group
resource "aws_db_subnet_group" "default" {
  name       = "default-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "Default DB Subnet Group"
  }
}

# Create an RDS instance configured for free tier
resource "aws_db_instance" "default" {
  identifier              = "free-tier-rds"
  engine                  = "mysql"        # Change to "postgres" if you prefer PostgreSQL
  engine_version          = "8.0"          # For MySQL; for PostgreSQL you might use "13.4" or similar
  instance_class          = "db.t2.micro"  # Free tier eligible
  allocated_storage       = 20             # Minimum for free tier
  storage_type            = "gp2"

  username                = var.db_username
  password                = var.db_password

  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  publicly_accessible     = true
  multi_az                = false

  skip_final_snapshot     = true

  tags = {
    Name = "FreeTierRDSInstance"
  }
}
