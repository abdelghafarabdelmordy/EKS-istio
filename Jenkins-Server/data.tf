data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical's AWS account ID

}
data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["*subnet-public*"] # Replace with your specific naming convention
  }

  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id] # Replace with your VPC ID reference
  }
}
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["*vpc*"] # Replace with your VPC name or tag
  }
}