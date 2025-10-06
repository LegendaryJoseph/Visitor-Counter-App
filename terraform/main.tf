resource "aws_vpc" "vc_main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "visitor-counter-vpc" }
}

resource "aws_subnet" "vc_public_subnet" {
  vpc_id            = aws_vpc.vc_main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "visitor-counter-public-subnet" }
}


resource "aws_internet_gateway" "vc_igw" {
  vpc_id = aws_vpc.vc_main.id
  tags   = { Name = "visitor-counter-igw" }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vc_main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vc_igw.id
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.vc_public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "vc_instance_sg" {
  name        = "visitor-counter-sg"
  description = "Allow Flask web (5000) and SSH"
  vpc_id      = aws_vpc.vc_main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Flask web"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "visitor-app-deployer-key"
  public_key = file("~/.ssh/visitorapp-key.pub")
}

resource "aws_instance" "visitor_counter_app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.vc_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.vc_instance_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  # user_data to install docker & docker-compose
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io docker-compose git

              systemctl enable docker
              systemctl start docker

              cd /home/ubuntu
              git clone ${var.github_repo}
              cd Visitor-Counter-App
              docker-compose up -d
              EOF

  tags = { Name = "visitor-counter-instance" }
}
