provider "aws" {
  region = "ap-south-1" 
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_instance.my_instance.id
  subnet_id      = aws_subnet.public_subnet_1.id
}

# S3 Bucket
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "my-unique-s3-bucket-name"
  acl    = "private"
}

# IAM Role
resource "aws_iam_role" "my_iam_role" {
  name = "my-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Security Group
resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Allow inbound traffic on port 22 and 80"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "my_instance" {
  ami             = "ami-0c55b159cbfafe1f0" 
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet_1.id
  security_group  = [aws_security_group.my_security_group.id]
  key_name        = "my-key-pair" 
  iam_instance_profile = aws_iam_instance_profile.my_instance_profile.name
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "my_instance_profile" {
  name = "my-instance-profile"

  roles = [aws_iam_role.my_iam_role.name]
}