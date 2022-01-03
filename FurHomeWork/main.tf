resource "aws_vpc" "DeVop" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "DeVop"
  }
}

resource "aws_subnet" "SnDeVop1" {
  vpc_id     = aws_vpc.DeVop.id
  cidr_block = var.subnet1_cidr

  tags = {
    Name = "SnDevop"
  }
}

resource "aws_subnet" "SnDeVop2" {
  vpc_id     = aws_vpc.DeVop.id
  cidr_block = var.subnet2_cidr

  tags = {
    Name = "SnDevop"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.DeVop.id

  tags = {
    Name = "gateway"
  }
}

resource "aws_nat_gateway" "NatGW" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.SnDeVop1.id
}


resource "aws_route_table" "RTSn" {
  vpc_id = aws_vpc.DeVop.id

  route {
    cidr_block = "0.0.0.0.0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "RTSn2" {
  vpc_id = aws_vpc.DeVop.id

  route {
    cidr_block = "0.0.0.0.0"
    nat_gateway_id = aws_nat_gateway.NatGW.id
  }
}


resource "aws_route_table_association" "SN1" {
  subnet_id      = aws_subnet.SnDeVop1.id
  route_table_id = aws_route_table.RTSn.id
}

resource "aws_route_table_association" "SN2" {
  subnet_id      = aws_subnet.SnDeVop2.id
  route_table_id = aws_route_table.RTSn2.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.DeVop.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_network_interface" "NTSN" {
  subnet_id   = aws_subnet.SnDeVop1.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "EC2" {
  ami           = "ami-0ed9277fb7eb570c9" # us-west-1
  instance_type = "t2.micro"
  key_name = "robertaTaf"
  subnet_id = aws_subnet.SnDeVop1.id

  network_interface {
    network_interface_id = aws_network_interface.NTSN.id
    device_index = 0
  }
}

resource "aws_instance" "needed" {
  ami           = "ami-0ed9277fb7eb570c9" # us-west-1
  instance_type = "t2.micro"
  key_name = "robertaTaf"
  subnet_id = aws_subnet.SnDeVop2.id

  network_interface {
    network_interface_id = aws_network_interface.NTSN.id
    device_index = 0
  }
}

resource "aws_kms_key" "my_key" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
}

resource "aws_db_instance" "database" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "database_instance"
  password             = "Angel4us"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  kms_key_id = aws_kms_key.my_key.id
  replica_mode = "moderat"
}

resource "aws_route53_zone" "dev" {
  name = "dev.automate.com"

  tags = {
    Environment = "dev"
  }
}

resource "aws_route53_record" "www-live" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 90
  }

  set_identifier = "live"
  records        = ["live.example.com"]
}

