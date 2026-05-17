resource "aws_eks_cluster" "this" {
  name    = var.cluster_name
  version = var.kubernetes_version

  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = length(var.pod_subnet_ids) > 0 ? var.pod_subnet_ids : var.private_subnet_ids
  }

  dynamic "encryption_config" {
    for_each = var.enable_kms_encryption ? [1] : []
    content {
      provider {
        key_arn = local.kms_key_arn
      }
      resources = ["secrets"]
    }
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = var.cluster_log_types

  dynamic "zonal_shift_config" {
    for_each = var.enable_zonal_shift ? [1] : []
    content {
      enabled = true
    }
  }

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.cluster_service_policy,
  ]
}

resource "aws_eks_access_entry" "nodes" {
  cluster_name  = aws_eks_cluster.this.id
  principal_arn = aws_iam_role.cluster.arn
  type          = "EC2_LINUX"
}
