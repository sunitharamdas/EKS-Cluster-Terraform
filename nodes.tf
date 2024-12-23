resource "aws_eks_node_group" "eks-nodegroup" {
  cluster_name    = aws_eks_cluster.eks-test.name
  node_group_name = "eks-nodegroup"
  node_role_arn   = aws_iam_role.node-iam-role.arn
  subnet_ids = module.vpc.private_subnets
  instance_types = ["t3.xlarge"]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }
  tags = {
    Name = "eks-node-group"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
resource "aws_iam_role" "node-iam-role" {
  name = "node-iam-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-iam-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-iam-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-iam-role.name
}

data "aws_availability_zones" "available" {
  state = "available"
}

# resource "aws_subnet" "eks-subnets" {
#   count = length(data.aws_availability_zones.available.names)
#   availability_zone = data.aws_availability_zones.available.names[count.index]
#   cidr_block = cidrsubnet(module.vpc.vpc_cidr_block, 8, count.index)
#   vpc_id            = module.vpc.vpc_id
#   tags = {
#     Name = "eks-subnet-${count.index}"
#   }
# }