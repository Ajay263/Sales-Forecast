# PostgreSQL RDS instance
resource "aws_db_instance" "postgres" {
  identifier           = "nexabrand-${var.environment}-postgres"
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = var.db_parameter_group_name
  
  # Network settings
  subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible  = true  # Set to false for production
  
  # Backup and maintenance
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  
  # Deletion protection
  deletion_protection     = false  # Set to true for production
  skip_final_snapshot     = true   # Set to false for production
  
  tags = {
    Name        = "nexabrand-${var.environment}-postgres"
    Environment = var.environment
  }
}