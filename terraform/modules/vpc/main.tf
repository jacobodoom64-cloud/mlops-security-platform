provider "aws" {
    region = "eu-north-1"
}


resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true 

    tags = {
        Name = "mlops-security-vpc"
    }
}


resource "aws_subnet" "public_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-north-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "mlops-public-subnet-a"
    }
}

resource "aws_subnet" "private_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-north-1a"

    tags = {
        Name = "mlops-private-subnet-a"
    }
}

resource "aws_internet_gateway" "main" { 
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "mlops-igw"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "mlops-public-rt"
    }
}

resource "aws_route_table_association" "public_a" {
    subnet_id = aws_subnet.public_a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
    domain = "vpc"

    tags = {
        Name = "mlops-nat-eip"
    }
}

resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public_a.id

    tags = {
        Name = "mlops-nat-gateway"
    }

    depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main.id
    }

    tags = {
        Name = "mlops-private-rt"
    }
}

resource "aws_route_table_association" "private_a" {
    subnet_id = aws_subnet.private_a.id
    route_table_id = aws_route_table.private.id
}