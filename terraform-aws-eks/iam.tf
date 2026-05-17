# ─── Cluster Role ───────────────────────────────────────────────────────────

data "aws_iam_policy_document" "cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

# ─── Nodes Role ─────────────────────────────────────────────────────────────

data "aws_iam_policy_document" "nodes_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "nodes" {
  name               = "${var.cluster_name}-nodes-role"
  assume_role_policy = data.aws_iam_policy_document.nodes_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "nodes_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_instance_profile" "nodes" {
  name = "${var.cluster_name}-nodes"
  role = aws_iam_role.nodes.name
  tags = var.tags
}

# ─── Cluster Autoscaler IRSA ─────────────────────────────────────────────────

data "aws_iam_policy_document" "autoscaler_assume" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-cluster-autoscaler"]
    }
  }
}

resource "aws_iam_role" "autoscaler" {
  count              = var.enable_cluster_autoscaler ? 1 : 0
  name               = "${var.cluster_name}-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.autoscaler_assume[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "autoscaler_policy" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstances",
      "ec2:DescribeLaunchTemplateVersions",
      "eks:DescribeNodegroup",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "autoscaler" {
  count  = var.enable_cluster_autoscaler ? 1 : 0
  name   = "${var.cluster_name}-autoscaler"
  policy = data.aws_iam_policy_document.autoscaler_policy[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "autoscaler" {
  count      = var.enable_cluster_autoscaler ? 1 : 0
  role       = aws_iam_role.autoscaler[0].name
  policy_arn = aws_iam_policy.autoscaler[0].arn
}

# ─── Node Termination Handler IRSA ───────────────────────────────────────────

data "aws_iam_policy_document" "nth_assume" {
  count = var.enable_node_termination_handler ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }
  }
}

resource "aws_iam_role" "nth" {
  count              = var.enable_node_termination_handler ? 1 : 0
  name               = "${var.cluster_name}-node-termination-handler"
  assume_role_policy = data.aws_iam_policy_document.nth_assume[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "nth_policy" {
  count = var.enable_node_termination_handler ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "nth" {
  count  = var.enable_node_termination_handler ? 1 : 0
  name   = "${var.cluster_name}-node-termination-handler"
  policy = data.aws_iam_policy_document.nth_policy[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "nth" {
  count      = var.enable_node_termination_handler ? 1 : 0
  role       = aws_iam_role.nth[0].name
  policy_arn = aws_iam_policy.nth[0].arn
}
