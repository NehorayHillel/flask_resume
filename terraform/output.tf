output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.your_ec2_instance.public_ip
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.your_rds_instance.endpoint
}
