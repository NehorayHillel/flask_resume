# Retrieve all subnets in the default VPC (you must have data "aws_vpc" "default" defined in main.tf)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create a DB subnet group for RDS
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
  engine                  = "mysql"         # Change to "postgres" if desired
  engine_version          = "8.0"           # For MySQL; adjust if using another engine
  instance_class          = "db.t2.micro"   # Free tier eligible
  allocated_storage       = 20              # Minimum required storage
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
