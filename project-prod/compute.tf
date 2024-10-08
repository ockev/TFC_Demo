
# pull latest AMI for ubuntu from AWS https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

# data "aws_ami" "latest-ubuntu" {
#     most_recent = true
#     owners = ["099720109477"] # Canonical

#     filter {
#         name   = "name"
#         values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
#     }

#     filter {
#         name   = "virtualization-type"
#         values = ["hvm"]
#     }
# }


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# Create web ubuntu server and install/enable apache2

resource "aws_instance" "web-server" {
  #  ami = "ami-013f17f36f8b1fefb" -- this would be for pinning a specific AMI for deployment
  #  ami = var.ami_id # -- same as above, this would be for pinning a specific AMI for deployment; but it would be passed in as a variable

    #use a data block to import newest ubunti ami
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    availability_zone = var.zone

    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.web-server-nic.id
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                EOF
    tags = {
        Name = "kevin-${var.env}-web-server"
        #use this to show Sentinel Policy check
        Department = "prod-apps"
        Billable = true 
    }
}

module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.0.1"
  # insert required variables here
}











# module "s3-bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "2.14.1"
#   # insert required variables here
# }








# module "s3-bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "2.6.0"
#   # insert required variables here
# }


#private module, doesn't seem to be working anymore
# module "s3-bucket" {
#   source  = "app.terraform.io/koconnor/s3-bucket/aws"
#   version = "2.5.0"
#   # insert required variables here
# }







#additional app server if needed for demo

/* resource "aws_instance" "app-server" {
    ami = data.aws_ami.latest-ubuntu.id
    instance_type = "t2.micro"
    availability_zone = var.zone
    
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.app-server-nic.id
    }

    tags = {
        Name = "kevin-${var.env}-app-server"
    }
} */
