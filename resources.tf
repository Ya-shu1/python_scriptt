provider "aws" {
  region = "us-east-1"
}



# creating vpc

resource "aws_vpc" "demovpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "Demo vpc"
  }
}



# creating 1st web subnet

resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.demovpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = "web subnet 1"
  }
}

# creating 2nd web subnet

resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.demovpc.id
  cidr_block        = var.subnet1_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = "web subnet 2"
  }
}



# creating internet gateway

resource "aws_internet_gateway" "demogateway" {
  vpc_id = aws_vpc.demovpc.id
}
# creating public route table

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.demovpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demogateway.id
  }
  tags = {
    Name = "route to internet"
  }
}

# associating 1st web route table

resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.route.id
}

# associating 2nd web route table

resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.route.id
}




#creating 1st ec2 instance in public subnet

resource "aws_instance" "demoinstance" {
  ami                         = "ami-06aa3f7caf3a30282"
  instance_type               = "t2.micro"
  key_name                    = "pem"
  vpc_security_group_ids      = ["${aws_security_group.demosg.id}"]
  subnet_id                   = aws_subnet.public-subnet-1.id
  associate_public_ip_address = true
  user_data                   = file("data.sh")
  tags = {
    Name = "my public instance"
  }
}
# create security group

resource "aws_security_group" "demosg" {
  vpc_id = aws_vpc.demovpc.id

  # inbound rules
  #HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #HTTP access from anywhere
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ssh access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #outbound rules
  #internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web sg"
  }
}
