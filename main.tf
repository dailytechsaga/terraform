variable "awsparameter" {
    type = "map"
    default = {
    region = "ca-central-1"
    vpc = "vpc-2a306942"
    ami = "ami-02e44367276fe7adc"
    itype = "t2.micro"
    subnet = "subnet-a16629c9"
    publicip = true
    keyname = "dailytechsaga"
    secgroupname = "dailytechsaga-test"
  }
}

provider "aws" {
  region = lookup(var.awsparameter, "region")
}

resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsparameter, "secgroupname")
  description = lookup(var.awsparameter, "secgroupname")
  vpc_id = lookup(var.awsparameter, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "project-iac" {
  ami = lookup(var.awsparameter, "ami")
  instance_type = lookup(var.awsparameter, "itype")
  subnet_id = lookup(var.awsparameter, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsparameter, "publicip")
  key_name = lookup(var.awsparameter, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
 #   iops = 150
    volume_size = 20
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-iac-sg ]
}


output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}
