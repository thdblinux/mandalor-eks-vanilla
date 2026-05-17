resource "helm_release" "cluster_autoscaler" {
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  name       = "aws-cluster-autoscaler"

  namespace        = "kube-system"
  create_namespace = true

  set = [
    {
      name  = "replicaCount"
      value = 1
    },
    {
      name  = "awsRegion"
      value = var.region
    },
    {
      name  = "rbac.serviceAccount.create"
      value = true
    },
    {
      name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.autoscaler.arn
    },
    {
      name  = "autoDiscovery.clusterName"
      value = aws_eks_cluster.main.id
    },
    {
      name  = "autoDiscovery.enabled"
      value = "true"
    }
  ]

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
  ]
}
