resource "aws_vpc" "main" {

    cidr_block = var.vpc_cidr
    enable_dns_hostnames = var.enable_dns_hostnames

    tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-vpc"
        }
    )
}


resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-igw"
        }
    )
}

resource "aws_subnet" "public_subnets" {
  
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-public-${local.az_names[count.index]}"
        }
    )
}

resource "aws_subnet" "private_subnets" {
  
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  
  tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-private-${local.az_names[count.index]}"
        }
    )
}


resource "aws_subnet" "database_subnets" {
  
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  
  tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-database-${local.az_names[count.index]}"
        }
    )
}

resource "aws_db_subnet_group" "db_group" {

  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.database_subnets[*].id

  tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}"
        }
    )
}


resource "aws_eip" "nat" {

  count = 2
  domain   = "vpc"
}

resource "aws_nat_gateway" "main" {

  count = length(aws_eip.nat)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-${local.az_names[count.index]}"
        }
    )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}


resource "aws_route_table" "public" {
  
  vpc_id = aws_vpc.main.id

  tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-public"
        }
    )

}

resource "aws_route_table" "private" {
  
  vpc_id = aws_vpc.main.id

  tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-private"
        }
    )

}

resource "aws_route_table" "database" {
  
  vpc_id = aws_vpc.main.id

  tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-database"
        }
    )

}


resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private_nat" {
  
  count = length(aws_nat_gateway.main)
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main[count.index].id
}

resource "aws_route" "database_nat" {

  count = length(aws_nat_gateway.main)
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "public" {

  count = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {

  count = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {

  count = length(aws_subnet.database_subnets)
  subnet_id      = aws_subnet.database_subnets[count.index].id
  route_table_id = aws_route_table.database.id
}