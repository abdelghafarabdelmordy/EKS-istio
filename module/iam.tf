
# Local Variables
locals {
  cluster_name = var.cluster-name
}

# Random Suffix for Unique Resource Names
resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

# ==========================================================================================
# IAM Role for EKS Cluster
# ==========================================================================================
resource "aws_iam_role" "eks-cluster-role" {
  count = var.is_eks_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count      = var.is_eks_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role[count.index].name
}

# ==========================================================================================
# IAM Role for EKS Node Group
# ==========================================================================================
resource "aws_iam_role" "eks-nodegroup-role" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-nodegroup-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonWorkerNodePolicy" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-nodegroup-role[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-nodegroup-role[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-nodegroup-role[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEBSCSIDriverPolicy" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks-nodegroup-role[count.index].name
}

# ==========================================================================================
# IAM Role for Addons
# ==========================================================================================
resource "aws_iam_role" "eks_addons_role" {
  name               = "${local.cluster_name}-addons-role-${random_integer.random_suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
}

# Custom IAM Policies
resource "aws_iam_policy" "s3_csi_driver_policy" {
  name   = "AmazonS3CSIDriverPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "efs_csi_driver_policy" {
  name   = "AmazonEFSCSIDriverPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:CreateAccessPoint",
          "elasticfilesystem:DeleteAccessPoint"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Addon Policies
resource "aws_iam_role_policy_attachment" "attach_s3_csi_driver" {
  role       = aws_iam_role.eks_addons_role.name
  policy_arn = aws_iam_policy.s3_csi_driver_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_efs_csi_driver" {
  role       = aws_iam_role.eks_addons_role.name
  policy_arn = aws_iam_policy.efs_csi_driver_policy.arn
}

# ==========================================================================================
# Attach Managed Policies for Monitoring and Observability
# ==========================================================================================
# resource "aws_iam_role_policy_attachment" "attach_guardduty_runtime_policy" {
#   role       = aws_iam_role.eks-nodegroup-role[0].name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonGuardDutyEKSRuntimeMonitoring"
# }

# resource "aws_iam_role_policy_attachment" "attach_cloudwatch_observability_policy" {
#   role       = aws_iam_role.eks-nodegroup-role[0].name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchObservabilityAccess"
# }

# resource "aws_iam_role_policy_attachment" "attach_network_flow_monitoring_policy" {
#   role       = aws_iam_role.eks-nodegroup-role[0].name
#   policy_arn = "arn:aws:iam::aws:policy/AWSNetworkFlowMonitoring"
# }

# ==========================================================================================
# OIDC Role and Policies
# ==========================================================================================
resource "aws_iam_role" "eks_oidc" {
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
  name               = "eks-oidc"
}

resource "aws_iam_policy" "eks-oidc-policy" {
  name = "test-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:ListAllMyBuckets", "s3:GetBucketLocation", "*"],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-oidc-policy-attach" {
  role       = aws_iam_role.eks_oidc.name
  policy_arn = aws_iam_policy.eks-oidc-policy.arn
}
