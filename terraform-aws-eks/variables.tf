# ─────────────────────────────────────────────
# Cluster
# ─────────────────────────────────────────────

variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS."
}

variable "kubernetes_version" {
  type        = string
  description = "Versão do Kubernetes."
  default     = "1.32"
}

variable "cluster_log_types" {
  type        = list(string)
  description = "Tipos de log do control plane a habilitar."
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "authentication_mode" {
  type        = string
  description = "Modo de autenticação do cluster (API | CONFIG_MAP | API_AND_CONFIG_MAP)."
  default     = "API_AND_CONFIG_MAP"
}

variable "enable_zonal_shift" {
  type        = bool
  description = "Habilita Zonal Shift no cluster."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags aplicadas a todos os recursos do módulo."
  default     = {}
}

# ─────────────────────────────────────────────
# Rede
# ─────────────────────────────────────────────

variable "vpc_id" {
  type        = string
  description = "ID da VPC onde o cluster será criado."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs das subnets privadas para os worker nodes."
}

variable "pod_subnet_ids" {
  type        = list(string)
  description = "IDs das subnets dedicadas para pods (Custom Networking)."
  default     = []
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "IDs das subnets públicas (para Load Balancers)."
  default     = []
}

# ─────────────────────────────────────────────
# KMS
# ─────────────────────────────────────────────

variable "enable_kms_encryption" {
  type        = bool
  description = "Habilita encriptação de secrets com KMS gerenciada pelo módulo."
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "ARN de uma KMS key existente. Se vazio e enable_kms_encryption=true, cria uma nova."
  default     = ""
}

# ─────────────────────────────────────────────
# Node Groups — principal (ON_DEMAND, AL2)
# ─────────────────────────────────────────────

variable "enable_node_group_main" {
  type        = bool
  description = "Habilita o node group principal (ON_DEMAND, Amazon Linux 2)."
  default     = true
}

variable "node_group_main_instance_types" {
  type        = list(string)
  description = "Tipos de instância do node group principal."
  default     = ["t3.xlarge"]
}

variable "node_group_main_scaling" {
  type = object({
    min     = number
    max     = number
    desired = number
  })
  description = "Configuração de scaling do node group principal."
  default = {
    min     = 1
    max     = 5
    desired = 2
  }
}

# ─────────────────────────────────────────────
# Node Groups — SPOT (AL2)
# ─────────────────────────────────────────────

variable "enable_node_group_spot" {
  type        = bool
  description = "Habilita o node group SPOT (Amazon Linux 2)."
  default     = false
}

variable "node_group_spot_instance_types" {
  type        = list(string)
  description = "Tipos de instância do node group SPOT."
  default     = ["t3.xlarge", "t3.2xlarge"]
}

variable "node_group_spot_scaling" {
  type = object({
    min     = number
    max     = number
    desired = number
  })
  description = "Configuração de scaling do node group SPOT."
  default = {
    min     = 1
    max     = 10
    desired = 2
  }
}

# ─────────────────────────────────────────────
# Node Groups — Critical (ON_DEMAND, Bottlerocket)
# ─────────────────────────────────────────────

variable "enable_node_group_critical" {
  type        = bool
  description = "Habilita o node group crítico (ON_DEMAND, Bottlerocket)."
  default     = false
}

variable "node_group_critical_instance_types" {
  type        = list(string)
  description = "Tipos de instância do node group crítico."
  default     = ["t3.xlarge"]
}

variable "node_group_critical_scaling" {
  type = object({
    min     = number
    max     = number
    desired = number
  })
  description = "Configuração de scaling do node group crítico."
  default = {
    min     = 1
    max     = 5
    desired = 2
  }
}

# ─────────────────────────────────────────────
# Node Groups — Graviton (ON_DEMAND, ARM64)
# ─────────────────────────────────────────────

variable "enable_node_group_graviton" {
  type        = bool
  description = "Habilita o node group Graviton ON_DEMAND (ARM64)."
  default     = false
}

variable "node_group_graviton_instance_types" {
  type        = list(string)
  description = "Tipos de instância Graviton (ARM64)."
  default     = ["t4g.large", "c7g.large"]
}

variable "node_group_graviton_scaling" {
  type = object({
    min     = number
    max     = number
    desired = number
  })
  description = "Configuração de scaling do node group Graviton."
  default = {
    min     = 1
    max     = 5
    desired = 1
  }
}

variable "enable_node_group_graviton_spot" {
  type        = bool
  description = "Habilita o node group Graviton SPOT (ARM64)."
  default     = false
}

variable "node_group_graviton_spot_scaling" {
  type = object({
    min     = number
    max     = number
    desired = number
  })
  description = "Configuração de scaling do node group Graviton SPOT."
  default = {
    min     = 1
    max     = 10
    desired = 1
  }
}

# ─────────────────────────────────────────────
# EKS Addons
# ─────────────────────────────────────────────

variable "eks_addons" {
  type = map(object({
    version                     = string
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    configuration_values        = optional(string, null)
  }))
  description = "Mapa de addons EKS a instalar. A chave é o nome do addon."
  default = {
    vpc-cni = {
      version = "v1.20.5-eksbuild.1"
    }
    coredns = {
      version = "v1.13.2-eksbuild.7"
    }
    kube-proxy = {
      version = "v1.34.6-eksbuild.2"
    }
    aws-ebs-csi-driver = {
      version = "v1.39.0-eksbuild.1"
    }
  }
}

# ─────────────────────────────────────────────
# Helm — Cluster Autoscaler
# ─────────────────────────────────────────────

variable "enable_cluster_autoscaler" {
  type        = bool
  description = "Instala o Cluster Autoscaler via Helm."
  default     = true
}

variable "cluster_autoscaler_chart_version" {
  type        = string
  description = "Versão do Helm chart do Cluster Autoscaler."
  default     = "9.57.0"
}

# ─────────────────────────────────────────────
# Helm — Metrics Server
# ─────────────────────────────────────────────

variable "enable_metrics_server" {
  type        = bool
  description = "Instala o Metrics Server via Helm."
  default     = true
}

variable "metrics_server_chart_version" {
  type        = string
  description = "Versão do Helm chart do Metrics Server."
  default     = "3.13.0"
}

# ─────────────────────────────────────────────
# Helm — Kube State Metrics
# ─────────────────────────────────────────────

variable "enable_kube_state_metrics" {
  type        = bool
  description = "Instala o Kube State Metrics via Helm."
  default     = true
}

variable "kube_state_metrics_chart_version" {
  type        = string
  description = "Versão do Helm chart do Kube State Metrics."
  default     = "5.30.0"
}

# ─────────────────────────────────────────────
# Helm — Node Termination Handler
# ─────────────────────────────────────────────

variable "enable_node_termination_handler" {
  type        = bool
  description = "Instala o AWS Node Termination Handler via Helm (recomendado com SPOT)."
  default     = false
}

variable "node_termination_handler_chart_version" {
  type        = string
  description = "Versão do Helm chart do AWS Node Termination Handler."
  default     = "0.21.0"
}

# ─────────────────────────────────────────────
# Helm — Ingress NGINX
# ─────────────────────────────────────────────

variable "enable_ingress_nginx" {
  type        = bool
  description = "Instala o Ingress NGINX Controller via Helm."
  default     = false
}

variable "ingress_nginx_chart_version" {
  type        = string
  description = "Versão do Helm chart do Ingress NGINX."
  default     = "4.12.2"
}

# ─────────────────────────────────────────────
# Helm — Cert Manager
# ─────────────────────────────────────────────

variable "enable_cert_manager" {
  type        = bool
  description = "Instala o Cert Manager via Helm."
  default     = false
}

variable "cert_manager_chart_version" {
  type        = string
  description = "Versão do Helm chart do Cert Manager."
  default     = "v1.17.2"
}
