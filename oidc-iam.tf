
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b1aa8f7e9d12c8f36"] # Default Amazon root CA thumbprint
  url            = data.aws_eks_cluster.eks_test.identity[0].oidc[0].issuer
}