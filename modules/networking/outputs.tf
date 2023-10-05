output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_CIDRs" {
  description = "CIDRS of the public subnets"
  value       = [for k, s in aws_subnet.public_subnets : s.cidr_block]
}

output "private_subnet_CIDR" {
  description = "IDs of the private subnets"
  value       = [for k, s in aws_subnet.private_subnets : s.cidr_block]
}
