output "vpc_id" {
  description = "SSM Parameter com o valor do vpc_id"
  value       = data.aws_ssm_parameter.vpc.value
  sensitive   = true
}

output "public_subnets" {
  description = "SSM Parameters com os valores dos ID's das Subnets Públicas"
  value       = data.aws_ssm_parameter.public_subnets[*].value
  sensitive   = true
}

output "private_subnets" {
  description = "SSM Parameters com os valores dos ID's das Subnets Privadas"
  value       = data.aws_ssm_parameter.private_subnets[*].value
  sensitive   = true
}

output "pod_subnets" {
  description = "SSM Parameters com os valores dos ID's das Subnets de Pods"
  value       = data.aws_ssm_parameter.pod_subnets[*].value
  sensitive   = true
}                                                        