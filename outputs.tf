# output "az_zones" {

#     value = data.aws_availability_zones.az_zones
# }

output "vpc_id" {

  value = aws_vpc.main.id   
}

output "public_subnet_ids"{
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids"  {
  value = aws_subnet.private_subnets[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database_subnets[*].id
}

output "database_subnet_group_name" {
  value = aws_db_subnet_group.db_group.name
}