MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    apiServerEndpoint: ${KUBERNETES_ENDPOINT}
    certificateAuthority: {KUBERNETES_CERT_ATHORITY}
    cidr: 172.20.0.0/16
    name: mandalor-{CLUS}
  kubelet:
    config:
      maxPods: 29
      clusterDNS:
      - 172.20.0.10

--//--