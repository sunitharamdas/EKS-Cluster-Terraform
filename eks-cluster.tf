resource "aws_eks_cluster" "eks-test" {
  name     = "eks-test"
  role_arn = aws_iam_role.eks-role.arn
  

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }


  tags = {
    cluster = "eks-demo"
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks-test.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-test.certificate_authority[0].data
}
