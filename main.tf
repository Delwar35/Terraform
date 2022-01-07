#  Let Terraform know who is our cloud provider

# AWS plugins/dependencies will be downloaded
provider "aws" {
    region = "eu-west-1"
    # This will allow terraform to create services on eu-west-1
  
}

# Let's start with Launching an ec2 instance using terraform
# creating a ec2 instance with defualt vpc and subnet
resource "aws_instance" "app_instance" {
  # add the ami  
  ami =  var.app_ami_id
  # choose t2
  instance_type = "t2.micro"
  #enable public IP
  associate_public_ip_address = true
  # add tags
  tags = {
      Name = "eng99_delwar_terraform_app"
  }
  
  key_name = "eng99" # ensure that we have key in .ssh file 
}

# To initialise we use terraform init
# terraform plan - checks the code 
# terraform apply - run the code
# terraform destroy - terminates ec2 instance 

# creating a vpc

resource "aws_vpc" "vpc_terraform" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "eng99_delwar_vpc_terraform"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "IG" {
    vpc_id = aws_vpc.vpc_terraform.id
    tags = {
        Name = "eng99_delwar_terraform_IG"
    }
}


# creating subnet inside a vpc
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc_terraform.id
  availability_zone = "eu-west-1a"
  cidr_block = "10.0.25.0/24"
  tags = {
        Name = "eng99_delwar_public_subnet_terraform"
    }
}

# Create a route table
resource "aws_route_table" "public_rt_terraform" {
    vpc_id = aws_vpc.vpc_terraform.id
         route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.IG.id
        }
    tags = {
      "Name" = "eng99_delwar_public_rt_terraform"
    }
}

# Route Table association
resource "aws_route_table_association" "public_rt_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt_terraform.id
    }

# creating security groups
resource "aws_security_group" "security_group" {
    # engress rules is the outbound rules
    # allow all outbound
    vpc_id = "vpc-08da03a1fba816a0d"
    egress {
        from_port = 0
        to_port = 0
        # can use "ALL" instead of "-1" 
        # "-1" and "ALL" can only be used if from_port and to_port is 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        
    }
    # ingress rules is the inbound rules

    # allow all to ssh to the machine with port 22
    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    # Allow the app to run
    ingress {
        from_port = "3000"
        to_port = "3000"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

     tags = {
        Name = "eng99_delwar_app_terraform_sg"
    }

  
} 


# creating a ec2 instance with a vpc and public subnet
resource "aws_instance" "app_instance2" {
  # add the ami  
  ami =  var.app_ami_id
  # choose t2
  instance_type = "t2.micro"
  #enable public IP
  associate_public_ip_address = true
  # associating subnet
  subnet_id = aws_subnet.public_subnet.id
  # associating security group
  vpc_security_group_ids = [aws_security_group.security_group.id]
  # add tags
  tags = {
      Name = "eng99_delwar_terraform_app2"
  }
  
  key_name = "eng99" # ensure that we have key in .ssh file 
}
# ---------------------------DB------------------------------------------------------

# creating subnet inside a vpc
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc_terraform.id 
  availability_zone = "eu-west-1a"
  cidr_block = "10.0.26.0/24"
  tags = {
        Name = "eng99_delwar_private_subnet_terraform"
    }
}

# Create a route table
resource "aws_route_table" "private_rt_terraform" {
    vpc_id = aws_vpc.vpc_terraform.id
         route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.IG.id
        }
    tags = {
      "Name" = "eng99_delwar_private_rt_terraform"
    }
}

# Route Table association
resource "aws_route_table_association" "private_rt_association" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt_terraform.id
    }

# creating security groups
resource "aws_security_group" "security_group_db" {
    # engress rules is the outbound rules
    # allow all outbound
    vpc_id = aws_vpc.vpc_terraform.id 

    egress {
        from_port = 0
        to_port = 0
        # can use "ALL" instead of "-1" 
        # "-1" and "ALL" can only be used if from_port and to_port is 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        
    }
    # ingress rules is the inbound rules

    # allow all to ssh to the machine with port 22
    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow the db to run
    ingress {
        from_port = "27017"
        to_port = "27017"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        
    }


    tags = {
        Name = "eng99_delwar_db_terraform_sg"
    }

  
} 


# creating a ec2 instance with a vpc and public subnet
resource "aws_instance" "db_instance" {
  # add the ami  
  ami =  var.app_ami_id
  # choose t2
  instance_type = "t2.micro"
  #enable public IP
  associate_public_ip_address = true
  # associating subnet
  subnet_id = aws_subnet.private_subnet.id
  # associating security group
  vpc_security_group_ids = [aws_security_group.security_group_db.id]
  # add tags
  tags = {
      Name = "eng99_delwar_terraform_db"
  }
  
  key_name = "eng99" # ensure that we have key in .ssh file 
}