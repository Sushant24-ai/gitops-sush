# VPC configuration for the EKS cluster

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # Required for EKS
  enable_nat_gateway     = true
  single_nat_gateway     = var.environment != "prod" # Use multiple NAT gateways in production
  one_nat_gateway_per_az = var.environment == "prod"
  enable_dns_hostnames   = true
  enable_dns_support     = true

  # Add VPC/Subnet tags required by EKS
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = local.tags
}

# Optionally create a bastion host in the public subnet for cluster access
resource "aws_instance" "bastion" {
  # Only create if ssh key is provided
  count = var.ec2_ssh_key_name != "" ? 1 : 0

  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  key_name               = var.ec2_ssh_key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true

  tags = merge(
    local.tags,
    {
      Name = "${local.cluster_name}-bastion"
    }
  )
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Output the bastion host's IP if created
output "bastion_ip" {
  description = "Public IP of the bastion host"
  value       = try(aws_instance.bastion[0].public_ip, "No bastion host created")
}
