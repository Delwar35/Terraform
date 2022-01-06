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

# creating subnet inside a vpc
resource "aws_subnet" "public_subnet" {
  vpc_id = "vpc-08da03a1fba816a0d"
  availability_zone = "eu-west-1a"
  cidr_block = "10.0.25.0/24"
  tags = {
        Name = "eng99_delwar_public_subnet_terraform"
    }
}

# creating security groups
resource "aws_security_group" "security_group" {
    # engress is the outbound rules
    # allow all outbound
    vpc_id = "vpc-08da03a1fba816a0d"
    egress {
        from_port = 0
        to_port = 0
        protocol = "ALL"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # ingress is the inbound rules
    # allow all to ssh
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

     tags = {
        Name = "eng99_delwar_app_terraform_sg"
    }

  
} 


# creating a ec2 instance with a vpc and public subnet
resource "aws_instance" "app_instance2" {
  # add the ami  
  ami =  "ami-07d8796a2b0f8d29c"
  # choose t2
  instance_type = "t2.micro"
  #enable public IP
  associate_public_ip_address = true
  # associating subnet
  subnet_id = "subnet-018ffac1021aa1997"
  # associating security group
  vpc_security_group_ids =["sg-0df8deb1c9b160f08"]
  # add tags
  tags = {
      Name = "eng99_delwar_terraform_app2"
  }
  
  key_name = "eng99" # ensure that we have key in .ssh file 
}