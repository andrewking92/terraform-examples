output "aws-subnet-infra-aws-mongodb-id" {
  description = "Subnet ID of root instances"
  value       = aws_subnet.infra-aws-mongodb.id
}

output "aws-security-group-infra-aws-mongodb-id" {
  description = "Security Group ID of root instances"
  value       = aws_default_security_group.infra-aws-mongodb.id
}
