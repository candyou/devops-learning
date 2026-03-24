# VPC principal
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Subnet public
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-subnet-public"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-rt-public"
    Environment = var.environment
  }
}

# Association Route Table → Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "k3s" {
  name        = "${var.project_name}-sg-k3s"
  description = "Security Group pour les noeuds K3s"
  vpc_id      = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort range
  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tout le trafic sortant autorisé
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg-k3s"
    Environment = var.environment
  }
}

# EC2 K3s Master
resource "aws_instance" "k3s_master" {
  ami                    = "ami-08b19810c28982c98" # Rocky Linux 9.7 eu-west-3
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.k3s.name

  # templatefile() lit le fichier .sh et remplace les variables
  user_data = templatefile("${path.module}/scripts/k3s-master.sh", {
    project_name = var.project_name
    aws_region   = var.aws_region
  })

  tags = {
    Name        = "${var.project_name}-k3s-master"
    Environment = var.environment
    Role        = "master"
  }
}

# EC2 K3s Worker
resource "aws_instance" "k3s_worker" {
  ami                    = "ami-08b19810c28982c98" # Rocky Linux 9.7 eu-west-3
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.k3s.name
  depends_on             = [aws_instance.k3s_master]

  user_data = templatefile("${path.module}/scripts/k3s-worker.sh", {
    project_name = var.project_name
    aws_region   = var.aws_region
    master_ip    = aws_instance.k3s_master.private_ip
  })

  tags = {
    Name        = "${var.project_name}-k3s-worker"
    Environment = var.environment
    Role        = "worker"
  }
}