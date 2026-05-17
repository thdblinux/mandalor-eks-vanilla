variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "cluster_name" {
  type    = string
  default = "my-eks-complete"
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC onde o cluster será criado."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs das subnets privadas."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "IDs das subnets públicas (para Load Balancers)."
  default     = []
}
