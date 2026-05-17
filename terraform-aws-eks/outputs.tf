# ─── Cluster ─────────────────────────────────────────────────────────────────

output "cluster_name" {
  description = "Nome do cluster EKS."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint da API do cluster EKS."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Certificado CA do cluster (base64)."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_version" {
  description = "Versão do Kubernetes do cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_arn" {
  description = "ARN do cluster EKS."
  value       = aws_eks_cluster.this.arn
}

output "cluster_security_group_id" {
  description = "ID do security group gerenciado pelo EKS (cluster SG)."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# ─── OIDC ─────────────────────────────────────────────────────────────────────

output "oidc_provider_arn" {
  description = "ARN do OIDC provider (usado para criar IRSA roles)."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "URL do OIDC provider sem o prefixo https://."
  value       = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}

# ─── IAM ──────────────────────────────────────────────────────────────────────

output "node_role_arn" {
  description = "ARN da IAM role dos worker nodes."
  value       = aws_iam_role.nodes.arn
}

output "cluster_role_arn" {
  description = "ARN da IAM role do cluster EKS."
  value       = aws_iam_role.cluster.arn
}

output "node_instance_profile_name" {
  description = "Nome do instance profile dos worker nodes."
  value       = aws_iam_instance_profile.nodes.name
}

# ─── KMS ──────────────────────────────────────────────────────────────────────

output "kms_key_arn" {
  description = "ARN da KMS key usada para encriptação de secrets (null se desabilitada)."
  value       = local.kms_key_arn
}

# ─── Auth ─────────────────────────────────────────────────────────────────────

output "cluster_token" {
  description = "Token de autenticação para o cluster (expira em 15 minutos)."
  value       = data.aws_eks_cluster_auth.this.token
  sensitive   = true
}

# ─── Autoscaler ───────────────────────────────────────────────────────────────

output "cluster_autoscaler_role_arn" {
  description = "ARN da IAM role do Cluster Autoscaler (IRSA). Vazio se desabilitado."
  value       = var.enable_cluster_autoscaler ? aws_iam_role.autoscaler[0].arn : null
}
