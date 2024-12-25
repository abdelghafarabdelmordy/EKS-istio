env                   = "Dev"
aws-region            = "eu-west-1"
vpc-cidr-block        = "10.16.0.0/16"
vpc-name              = "vpc"
igw-name              = "igw"
pub-subnet-count      = 3
pub-cidr-block        = ["10.16.0.0/20", "10.16.16.0/20", "10.16.32.0/20"]
pub-availability-zone = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
pub-sub-name          = "subnet-public"
pri-subnet-count      = 3
pri-cidr-block        = ["10.16.128.0/20", "10.16.144.0/20", "10.16.160.0/20"]
pri-availability-zone = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
pri-sub-name          = "subnet-private"
public-rt-name        = "public-route-table"
private-rt-name       = "private-route-table"
eip-name              = "elasticip-ngw"
ngw-name              = "ngw"
eks-sg                = "eks-sg"

# EKS
is-eks-cluster-enabled     = true
cluster-version            = "1.31"
cluster-name               = "eks-cluster"
endpoint-private-access    = true
endpoint-public-access     = true
ondemand_instance_types    = ["t3.large"]

desired_capacity_on_demand = "2"
min_capacity_on_demand     = "2"
max_capacity_on_demand     = "2"
# spot_instance_types        = ["t3.micro", "t3a.micro"]
# desired_capacity_spot      = "1"
# min_capacity_spot          = "1"
# max_capacity_spot          = "1"
addons = [
  {
      name    = "vpc-cni"
      version = "v1.19.0-eksbuild.1"  # Replace with the latest compatible version
    },
    {
      name    = "coredns"
      version = "v1.11.3-eksbuild.2"  # Replace with the latest compatible version
    },
    {
      name    = "kube-proxy"
      version = "v1.31.3-eksbuild.2"  # Replace with the latest compatible version
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.37.0-eksbuild.1"  # Replace with the latest compatible version
    },
  # Add more addons as needed
]
