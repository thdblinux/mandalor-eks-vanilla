data "aws_security_group" "node" {
  tags = {
    "aws:eks:cluster-name" = aws_eks_cluster.this.name
  }

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_node_group.spot,
    aws_eks_node_group.critical,
    aws_eks_node_group.graviton,
    aws_eks_node_group.graviton_spot,
  ]
}

resource "aws_vpc_security_group_ingress_rule" "nodeport" {
  security_group_id = data.aws_security_group.node.id
  description       = "Allow NodePort services from VPC"
  from_port         = 30000
  to_port           = 32767
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.tags, { Name = "${var.cluster_name}-nodeport" })
}

resource "aws_vpc_security_group_ingress_rule" "coredns_tcp" {
  security_group_id            = data.aws_security_group.node.id
  description                  = "Allow CoreDNS TCP between nodes"
  from_port                    = 53
  to_port                      = 53
  ip_protocol                  = "tcp"
  referenced_security_group_id = data.aws_security_group.node.id

  tags = merge(var.tags, { Name = "${var.cluster_name}-coredns-tcp" })
}

resource "aws_vpc_security_group_ingress_rule" "coredns_udp" {
  security_group_id            = data.aws_security_group.node.id
  description                  = "Allow CoreDNS UDP between nodes"
  from_port                    = 53
  to_port                      = 53
  ip_protocol                  = "udp"
  referenced_security_group_id = data.aws_security_group.node.id

  tags = merge(var.tags, { Name = "${var.cluster_name}-coredns-udp" })
}
