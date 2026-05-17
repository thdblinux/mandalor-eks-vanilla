locals {
  any_node_group_enabled = (
    var.enable_node_group_main ||
    var.enable_node_group_spot ||
    var.enable_node_group_critical ||
    var.enable_node_group_graviton ||
    var.enable_node_group_graviton_spot
  )

  node_group_deps = compact([
    var.enable_node_group_main ? "main" : null,
    var.enable_node_group_spot ? "spot" : null,
  ])
}

# ─── Cluster Autoscaler ───────────────────────────────────────────────────────

resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  name             = "aws-cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "kube-system"
  create_namespace = true
  version          = var.cluster_autoscaler_chart_version
  atomic           = true

  set = [
    { name = "replicaCount", value = "1" },
    { name = "awsRegion", value = data.aws_region.current.name },
    { name = "rbac.serviceAccount.create", value = "true" },
    { name = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = aws_iam_role.autoscaler[0].arn },
    { name = "autoDiscovery.clusterName", value = aws_eks_cluster.this.id },
    { name = "autoDiscovery.enabled", value = "true" },
  ]

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_node_group.spot,
    aws_eks_node_group.critical,
    aws_eks_node_group.graviton,
    aws_eks_node_group.graviton_spot,
    aws_eks_addon.this,
  ]
}

# ─── Metrics Server ───────────────────────────────────────────────────────────

resource "helm_release" "metrics_server" {
  count = var.enable_metrics_server ? 1 : 0

  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = "kube-system"
  create_namespace = true
  version          = var.metrics_server_chart_version
  atomic           = true

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_node_group.spot,
    aws_eks_addon.this,
  ]
}

# ─── Kube State Metrics ───────────────────────────────────────────────────────

resource "helm_release" "kube_state_metrics" {
  count = var.enable_kube_state_metrics ? 1 : 0

  name             = "kube-state-metrics"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-state-metrics"
  namespace        = "kube-system"
  create_namespace = true
  version          = var.kube_state_metrics_chart_version
  atomic           = true

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_node_group.spot,
    aws_eks_addon.this,
  ]
}

# ─── Node Termination Handler ─────────────────────────────────────────────────

resource "helm_release" "node_termination_handler" {
  count = var.enable_node_termination_handler ? 1 : 0

  name             = "aws-node-termination-handler"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-node-termination-handler"
  namespace        = "kube-system"
  create_namespace = true
  version          = var.node_termination_handler_chart_version
  atomic           = true

  set = [
    { name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = aws_iam_role.nth[0].arn },
  ]

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_node_group.spot,
    aws_eks_addon.this,
  ]
}

# ─── Ingress NGINX ────────────────────────────────────────────────────────────

resource "helm_release" "ingress_nginx" {
  count = var.enable_ingress_nginx ? 1 : 0

  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = var.ingress_nginx_chart_version
  atomic           = true

  set = [
    { name = "controller.service.type", value = "LoadBalancer" },
  ]

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_node_group.spot,
    aws_eks_addon.this,
  ]
}

# ─── Cert Manager ─────────────────────────────────────────────────────────────

resource "helm_release" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = var.cert_manager_chart_version
  atomic           = true

  set = [
    { name = "crds.enabled", value = "true" },
  ]

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_node_group.spot,
    aws_eks_addon.this,
  ]
}
