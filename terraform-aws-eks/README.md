# terraform-aws-eks

Módulo Terraform para provisionar um cluster EKS na AWS com suporte a múltiplos node groups, addons gerenciados e Helm charts opcionais.

## Features

- Cluster EKS com controle de logging, autenticação e zonal shift
- Criptografia de secrets via KMS (chave gerenciada ou BYO)
- OIDC provider para IRSA (IAM Roles for Service Accounts)
- Node Groups: ON_DEMAND, SPOT, Bottlerocket (critical), Graviton (ARM64)
- Auto-discovery do Cluster Autoscaler via tags nos ASGs
- Addons EKS configuráveis via mapa (`eks_addons`)
- Helm charts opcionais: Cluster Autoscaler, Metrics Server, Kube State Metrics, Node Termination Handler, Ingress NGINX, Cert Manager

## Usage

```hcl
module "eks" {
  source = "github.com/seu-org/terraform-aws-eks"

  cluster_name       = "meu-cluster"
  kubernetes_version = "1.32"

  vpc_id             = "vpc-xxxx"
  private_subnet_ids = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

  enable_node_group_main = true
  node_group_main_scaling = {
    min     = 2
    max     = 10
    desired = 2
  }

  enable_cluster_autoscaler = true
  enable_metrics_server     = true

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

### Provider configuration (caller)

```hcl
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = module.eks.cluster_token
  }
}
```

## Examples

- [simple](./examples/simple) — cluster mínimo com 1 node group ON_DEMAND
- [complete](./examples/complete) — cluster completo com todos os node groups e Helm charts

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.80.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.80.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 3.0.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_access_entry.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.critical](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_node_group.graviton](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_node_group.graviton_spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_node_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_node_group.spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_instance_profile.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.nth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.nth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_vpc_security_group_ingress_rule.coredns_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.coredns_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodeport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kube_state_metrics](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.node_termination_handler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.autoscaler_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.autoscaler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nodes_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nth_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nth_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_security_group.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [tls_certificate.eks](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | Modo de autenticação do cluster (API \| CONFIG\_MAP \| API\_AND\_CONFIG\_MAP). | `string` | `"API_AND_CONFIG_MAP"` | no |
| <a name="input_cert_manager_chart_version"></a> [cert\_manager\_chart\_version](#input\_cert\_manager\_chart\_version) | Versão do Helm chart do Cert Manager. | `string` | `"v1.17.2"` | no |
| <a name="input_cluster_autoscaler_chart_version"></a> [cluster\_autoscaler\_chart\_version](#input\_cluster\_autoscaler\_chart\_version) | Versão do Helm chart do Cluster Autoscaler. | `string` | `"9.57.0"` | no |
| <a name="input_cluster_log_types"></a> [cluster\_log\_types](#input\_cluster\_log\_types) | Tipos de log do control plane a habilitar. | `list(string)` | <pre>[<br/>  "api",<br/>  "audit",<br/>  "authenticator",<br/>  "controllerManager",<br/>  "scheduler"<br/>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Nome do cluster EKS. | `string` | n/a | yes |
| <a name="input_eks_addons"></a> [eks\_addons](#input\_eks\_addons) | Mapa de addons EKS a instalar. A chave é o nome do addon. | <pre>map(object({<br/>    version                     = string<br/>    resolve_conflicts_on_create = optional(string, "OVERWRITE")<br/>    resolve_conflicts_on_update = optional(string, "OVERWRITE")<br/>    configuration_values        = optional(string, null)<br/>  }))</pre> | <pre>{<br/>  "aws-ebs-csi-driver": {<br/>    "version": "v1.39.0-eksbuild.1"<br/>  },<br/>  "coredns": {<br/>    "version": "v1.13.2-eksbuild.7"<br/>  },<br/>  "kube-proxy": {<br/>    "version": "v1.34.6-eksbuild.2"<br/>  },<br/>  "vpc-cni": {<br/>    "version": "v1.20.5-eksbuild.1"<br/>  }<br/>}</pre> | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Instala o Cert Manager via Helm. | `bool` | `false` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable\_cluster\_autoscaler](#input\_enable\_cluster\_autoscaler) | Instala o Cluster Autoscaler via Helm. | `bool` | `true` | no |
| <a name="input_enable_ingress_nginx"></a> [enable\_ingress\_nginx](#input\_enable\_ingress\_nginx) | Instala o Ingress NGINX Controller via Helm. | `bool` | `false` | no |
| <a name="input_enable_kms_encryption"></a> [enable\_kms\_encryption](#input\_enable\_kms\_encryption) | Habilita encriptação de secrets com KMS gerenciada pelo módulo. | `bool` | `true` | no |
| <a name="input_enable_kube_state_metrics"></a> [enable\_kube\_state\_metrics](#input\_enable\_kube\_state\_metrics) | Instala o Kube State Metrics via Helm. | `bool` | `true` | no |
| <a name="input_enable_metrics_server"></a> [enable\_metrics\_server](#input\_enable\_metrics\_server) | Instala o Metrics Server via Helm. | `bool` | `true` | no |
| <a name="input_enable_node_group_critical"></a> [enable\_node\_group\_critical](#input\_enable\_node\_group\_critical) | Habilita o node group crítico (ON\_DEMAND, Bottlerocket). | `bool` | `false` | no |
| <a name="input_enable_node_group_graviton"></a> [enable\_node\_group\_graviton](#input\_enable\_node\_group\_graviton) | Habilita o node group Graviton ON\_DEMAND (ARM64). | `bool` | `false` | no |
| <a name="input_enable_node_group_graviton_spot"></a> [enable\_node\_group\_graviton\_spot](#input\_enable\_node\_group\_graviton\_spot) | Habilita o node group Graviton SPOT (ARM64). | `bool` | `false` | no |
| <a name="input_enable_node_group_main"></a> [enable\_node\_group\_main](#input\_enable\_node\_group\_main) | Habilita o node group principal (ON\_DEMAND, Amazon Linux 2). | `bool` | `true` | no |
| <a name="input_enable_node_group_spot"></a> [enable\_node\_group\_spot](#input\_enable\_node\_group\_spot) | Habilita o node group SPOT (Amazon Linux 2). | `bool` | `false` | no |
| <a name="input_enable_node_termination_handler"></a> [enable\_node\_termination\_handler](#input\_enable\_node\_termination\_handler) | Instala o AWS Node Termination Handler via Helm (recomendado com SPOT). | `bool` | `false` | no |
| <a name="input_enable_zonal_shift"></a> [enable\_zonal\_shift](#input\_enable\_zonal\_shift) | Habilita Zonal Shift no cluster. | `bool` | `true` | no |
| <a name="input_ingress_nginx_chart_version"></a> [ingress\_nginx\_chart\_version](#input\_ingress\_nginx\_chart\_version) | Versão do Helm chart do Ingress NGINX. | `string` | `"4.12.2"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN de uma KMS key existente. Se vazio e enable\_kms\_encryption=true, cria uma nova. | `string` | `""` | no |
| <a name="input_kube_state_metrics_chart_version"></a> [kube\_state\_metrics\_chart\_version](#input\_kube\_state\_metrics\_chart\_version) | Versão do Helm chart do Kube State Metrics. | `string` | `"5.30.0"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Versão do Kubernetes. | `string` | `"1.32"` | no |
| <a name="input_metrics_server_chart_version"></a> [metrics\_server\_chart\_version](#input\_metrics\_server\_chart\_version) | Versão do Helm chart do Metrics Server. | `string` | `"3.13.0"` | no |
| <a name="input_node_group_critical_instance_types"></a> [node\_group\_critical\_instance\_types](#input\_node\_group\_critical\_instance\_types) | Tipos de instância do node group crítico. | `list(string)` | <pre>[<br/>  "t3.xlarge"<br/>]</pre> | no |
| <a name="input_node_group_critical_scaling"></a> [node\_group\_critical\_scaling](#input\_node\_group\_critical\_scaling) | Configuração de scaling do node group crítico. | <pre>object({<br/>    min     = number<br/>    max     = number<br/>    desired = number<br/>  })</pre> | <pre>{<br/>  "desired": 2,<br/>  "max": 5,<br/>  "min": 1<br/>}</pre> | no |
| <a name="input_node_group_graviton_instance_types"></a> [node\_group\_graviton\_instance\_types](#input\_node\_group\_graviton\_instance\_types) | Tipos de instância Graviton (ARM64). | `list(string)` | <pre>[<br/>  "t4g.large",<br/>  "c7g.large"<br/>]</pre> | no |
| <a name="input_node_group_graviton_scaling"></a> [node\_group\_graviton\_scaling](#input\_node\_group\_graviton\_scaling) | Configuração de scaling do node group Graviton. | <pre>object({<br/>    min     = number<br/>    max     = number<br/>    desired = number<br/>  })</pre> | <pre>{<br/>  "desired": 1,<br/>  "max": 5,<br/>  "min": 1<br/>}</pre> | no |
| <a name="input_node_group_graviton_spot_scaling"></a> [node\_group\_graviton\_spot\_scaling](#input\_node\_group\_graviton\_spot\_scaling) | Configuração de scaling do node group Graviton SPOT. | <pre>object({<br/>    min     = number<br/>    max     = number<br/>    desired = number<br/>  })</pre> | <pre>{<br/>  "desired": 1,<br/>  "max": 10,<br/>  "min": 1<br/>}</pre> | no |
| <a name="input_node_group_main_instance_types"></a> [node\_group\_main\_instance\_types](#input\_node\_group\_main\_instance\_types) | Tipos de instância do node group principal. | `list(string)` | <pre>[<br/>  "t3.xlarge"<br/>]</pre> | no |
| <a name="input_node_group_main_scaling"></a> [node\_group\_main\_scaling](#input\_node\_group\_main\_scaling) | Configuração de scaling do node group principal. | <pre>object({<br/>    min     = number<br/>    max     = number<br/>    desired = number<br/>  })</pre> | <pre>{<br/>  "desired": 2,<br/>  "max": 5,<br/>  "min": 1<br/>}</pre> | no |
| <a name="input_node_group_spot_instance_types"></a> [node\_group\_spot\_instance\_types](#input\_node\_group\_spot\_instance\_types) | Tipos de instância do node group SPOT. | `list(string)` | <pre>[<br/>  "t3.xlarge",<br/>  "t3.2xlarge"<br/>]</pre> | no |
| <a name="input_node_group_spot_scaling"></a> [node\_group\_spot\_scaling](#input\_node\_group\_spot\_scaling) | Configuração de scaling do node group SPOT. | <pre>object({<br/>    min     = number<br/>    max     = number<br/>    desired = number<br/>  })</pre> | <pre>{<br/>  "desired": 2,<br/>  "max": 10,<br/>  "min": 1<br/>}</pre> | no |
| <a name="input_node_termination_handler_chart_version"></a> [node\_termination\_handler\_chart\_version](#input\_node\_termination\_handler\_chart\_version) | Versão do Helm chart do AWS Node Termination Handler. | `string` | `"0.21.0"` | no |
| <a name="input_pod_subnet_ids"></a> [pod\_subnet\_ids](#input\_pod\_subnet\_ids) | IDs das subnets dedicadas para pods (Custom Networking). | `list(string)` | `[]` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | IDs das subnets privadas para os worker nodes. | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | IDs das subnets públicas (para Load Balancers). | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags aplicadas a todos os recursos do módulo. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID da VPC onde o cluster será criado. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN do cluster EKS. |
| <a name="output_cluster_autoscaler_role_arn"></a> [cluster\_autoscaler\_role\_arn](#output\_cluster\_autoscaler\_role\_arn) | ARN da IAM role do Cluster Autoscaler (IRSA). Vazio se desabilitado. |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Certificado CA do cluster (base64). |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint da API do cluster EKS. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Nome do cluster EKS. |
| <a name="output_cluster_role_arn"></a> [cluster\_role\_arn](#output\_cluster\_role\_arn) | ARN da IAM role do cluster EKS. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | ID do security group gerenciado pelo EKS (cluster SG). |
| <a name="output_cluster_token"></a> [cluster\_token](#output\_cluster\_token) | Token de autenticação para o cluster (expira em 15 minutos). |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | Versão do Kubernetes do cluster. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN da KMS key usada para encriptação de secrets (null se desabilitada). |
| <a name="output_node_instance_profile_name"></a> [node\_instance\_profile\_name](#output\_node\_instance\_profile\_name) | Nome do instance profile dos worker nodes. |
| <a name="output_node_role_arn"></a> [node\_role\_arn](#output\_node\_role\_arn) | ARN da IAM role dos worker nodes. |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN do OIDC provider (usado para criar IRSA roles). |
| <a name="output_oidc_provider_url"></a> [oidc\_provider\_url](#output\_oidc\_provider\_url) | URL do OIDC provider sem o prefixo https://. |
<!-- END_TF_DOCS -->