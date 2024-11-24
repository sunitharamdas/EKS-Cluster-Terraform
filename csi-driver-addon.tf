data "aws_eks_cluster" "eks-test" {
  name = "eks-test" # Replace "demo" with the actual cluster name
}

resource "aws_iam_role" "eks_ebs_csi_driver" {
  name = "eks-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_eks_addon" "csi_driver" {
  cluster_name             = data.aws_eks_cluster.eks-test.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.30.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}