resource "aws_eks_addon" "this" {
  for_each = var.eks_addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  configuration_values        = each.value.configuration_values

  tags = var.tags

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_node_group.spot,
    aws_eks_node_group.critical,
    aws_eks_node_group.graviton,
    aws_eks_node_group.graviton_spot,
  ]
}
