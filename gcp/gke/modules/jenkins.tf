resource "helm_release" "jenkins-chart" {
  count            = var.enable_jenkins
  name             = "jenkins"
  chart            = "jenkins"
  version          = "4.2.8"
  repository       = "https://charts.jenkins.io"
  namespace        = "jenkins"
  create_namespace = true
  values = [<<EOF
controller:
  jenkinsUriPrefix: "/jenkins"
  ingress:
    enabled: true
    path: /jenkins
    hostName: "${local.full_dns}" 
    annotations:
      apiVersion: networking.k8s.io/v1
      kubernetes.io/ingress.allow-http: "false"
      kubernetes.io/ingress.class: "traefik"
      external-dns.alpha.kubernetes.io/hostname: "${local.full_dns}"
  installPlugins:
    - kubernetes:latest
    - workflow-job:latest
    - workflow-aggregator:latest
    - credentials-binding:latest
    - git:latest
    - google-oauth-plugin:latest
    - google-source-plugin:latest
    - google-kubernetes-engine:latest
    - google-storage-plugin:latest
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: role
          operator: In
          values:
          - master
  EOF
  ]

  set {
    name  = "controller.resources.requests.cpu"
    value = "50m"
  }
  set {
    name  = "controller.resources.requests.memory"
    value = "1024Mi"
  }
  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }
  set {
    name  = "controller.resources.limits.memory"
    value = "3500Mi"
  }
  set {
    name  = "controller.javaOpts"
    value = "-Xms3500m -Xmx3500m"
  }
  set {
    name  = "agent.resources.requests.cpu"
    value = "500m"
  }
  set {
    name  = "agent.resources.requests.memory"
    value = "256Mi"
  }
  set {
    name  = "agent.resources.limits.cpu"
    value = "1"
  }
  set {
    name  = "agent.resources.limits.memory"
    value = "512Mi"
  }
  set {
    name  = "persistence.size"
    value = "10Gi"
  }
  set {
    name  = "serviceAccount.name"
    value = "jenkins-ns"
  }

  depends_on = [
    module.gke,
    helm_release.ingress-controller,
    helm_release.external-dns
  ]
}
