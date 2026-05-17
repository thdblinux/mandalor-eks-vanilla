locals {
  autoscaler_tags = var.enable_cluster_autoscaler ? {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  } : {}
}

# ─── Main (ON_DEMAND, Amazon Linux 2) ───────────────────────────────────────

resource "aws_eks_node_group" "main" {
  count = var.enable_node_group_main ? 1 : 0

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-main"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_group_main_instance_types
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2_x86_64"

  scaling_config {
    min_size     = var.node_group_main_scaling.min
    max_size     = var.node_group_main_scaling.max
    desired_size = var.node_group_main_scaling.desired
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "role"     = "main"
    "capacity" = "on-demand"
    "node-os"  = "al2"
  }

  tags = merge(var.tags, local.autoscaler_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  depends_on = [
    aws_iam_role_policy_attachment.nodes_worker,
    aws_iam_role_policy_attachment.nodes_cni,
    aws_iam_role_policy_attachment.nodes_ecr,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# ─── SPOT (Amazon Linux 2) ───────────────────────────────────────────────────

resource "aws_eks_node_group" "spot" {
  count = var.enable_node_group_spot ? 1 : 0

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-spot"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_group_spot_instance_types
  capacity_type  = "SPOT"
  ami_type       = "AL2_x86_64"

  scaling_config {
    min_size     = var.node_group_spot_scaling.min
    max_size     = var.node_group_spot_scaling.max
    desired_size = var.node_group_spot_scaling.desired
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "role"     = "spot"
    "capacity" = "spot"
    "node-os"  = "al2"
  }

  taint {
    key    = "spot"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  tags = merge(var.tags, local.autoscaler_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  depends_on = [
    aws_iam_role_policy_attachment.nodes_worker,
    aws_iam_role_policy_attachment.nodes_cni,
    aws_iam_role_policy_attachment.nodes_ecr,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# ─── Critical (ON_DEMAND, Bottlerocket) ──────────────────────────────────────

resource "aws_eks_node_group" "critical" {
  count = var.enable_node_group_critical ? 1 : 0

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-critical"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_group_critical_instance_types
  capacity_type  = "ON_DEMAND"
  ami_type       = "BOTTLEROCKET_x86_64"

  scaling_config {
    min_size     = var.node_group_critical_scaling.min
    max_size     = var.node_group_critical_scaling.max
    desired_size = var.node_group_critical_scaling.desired
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "role"     = "critical"
    "capacity" = "on-demand"
    "node-os"  = "bottlerocket"
  }

  taint {
    key    = "critical"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  tags = merge(var.tags, local.autoscaler_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  depends_on = [
    aws_iam_role_policy_attachment.nodes_worker,
    aws_iam_role_policy_attachment.nodes_cni,
    aws_iam_role_policy_attachment.nodes_ecr,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# ─── Graviton ON_DEMAND (ARM64) ──────────────────────────────────────────────

resource "aws_eks_node_group" "graviton" {
  count = var.enable_node_group_graviton ? 1 : 0

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-graviton"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_group_graviton_instance_types
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2_ARM_64"

  scaling_config {
    min_size     = var.node_group_graviton_scaling.min
    max_size     = var.node_group_graviton_scaling.max
    desired_size = var.node_group_graviton_scaling.desired
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "role"               = "graviton"
    "capacity"           = "on-demand"
    "node-os"            = "al2"
    "kubernetes.io/arch" = "arm64"
  }

  tags = merge(var.tags, local.autoscaler_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  depends_on = [
    aws_iam_role_policy_attachment.nodes_worker,
    aws_iam_role_policy_attachment.nodes_cni,
    aws_iam_role_policy_attachment.nodes_ecr,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# ─── Graviton SPOT (ARM64) ───────────────────────────────────────────────────

resource "aws_eks_node_group" "graviton_spot" {
  count = var.enable_node_group_graviton_spot ? 1 : 0

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-graviton-spot"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_group_graviton_instance_types
  capacity_type  = "SPOT"
  ami_type       = "AL2_ARM_64"

  scaling_config {
    min_size     = var.node_group_graviton_spot_scaling.min
    max_size     = var.node_group_graviton_spot_scaling.max
    desired_size = var.node_group_graviton_spot_scaling.desired
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "role"               = "graviton-spot"
    "capacity"           = "spot"
    "node-os"            = "al2"
    "kubernetes.io/arch" = "arm64"
  }

  taint {
    key    = "spot"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  tags = merge(var.tags, local.autoscaler_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  depends_on = [
    aws_iam_role_policy_attachment.nodes_worker,
    aws_iam_role_policy_attachment.nodes_cni,
    aws_iam_role_policy_attachment.nodes_ecr,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
