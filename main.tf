# configure aws provider
provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = "us-east-1"
    #profile = "Admin"
}

# Create VPC make sure to include a cidr range 
resource "aws_vpc" "dep5vpc" {
 cidr_block = "10.0.0.0/16"

 tags = {
   Name = "Deployment5VPC"
 }
}

# Creating Public Subnet 2 (us-east-1b)
resource "aws_subnet" "public_subnetb" {
 vpc_id     = aws_vpc.dep5vpc.id
 availability_zone = "us-east-1b"
 cidr_block = "10.0.1.0/24"
 map_public_ip_on_launch = true 
 tags = {
   Name = "PublicSubnet1b"
 }
}

# Creating Public Subnet 1 (us-east-1a)
resource "aws_subnet" "public_subneta" {
 vpc_id     = aws_vpc.dep5vpc.id
 availability_zone = "us-east-1a"
 cidr_block = "10.0.2.0/24"
 map_public_ip_on_launch = true 
 tags = {
   Name = "PublicSubnet1a"
 }
}

# Making an Internet Gateway
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.dep5vpc.id
 
 tags = {
   Name = "dep5_IG"
 }
}

# Creating Security Group to include ports 22, 8080, 8000 of ingress 
 resource "aws_security_group" "dep5sg" {
 name = "deployment5_SG"
 vpc_id = aws_vpc.dep5vpc.id

 ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

 }

 ingress {
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
 }

 ingress {
  from_port = 8000
  to_port = 8000
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
 }

 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 tags = {
  "Name" : "deployment5_SG"
  "Terraform" : "true"
 }

}



#associating the default route table that Terraform will create with the internet gateway and everything that exists within the vpc 
resource "aws_default_route_table" "deproute5" {
  default_route_table_id = aws_vpc.dep5vpc.default_route_table_id
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}



# Create Instance 1 (Jenkins)
resource "aws_instance" "instance1" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.medium"
  key_name               = "SameenKhan822key"
  subnet_id              = aws_subnet.public_subneta.id
  vpc_security_group_ids = [aws_security_group.dep5sg.id]
  user_data = "${file("jenkins.sh")}"
  
  
  tags = {
    "Name" : "Deployment5-tf1"
  }
}

# Create Instance 2 (Application)
resource "aws_instance" "instance2" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.medium"
  key_name               = "SameenKhan822key"
  subnet_id              = aws_subnet.public_subnetb.id
  vpc_security_group_ids = [aws_security_group.dep5sg.id]
  
  
  tags = {
    "Name" : "Deployment5-tf2"
  }
}
