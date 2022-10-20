resource "kubernetes_namespace" "jenkins-ns" {
  metadata {
    name = "jenkins"
  }
}

resource "helm_release" "jenkins-chart" {
  name             = "jenkins"
  chart            = "jenkins"
  version          = "4.2.8"
  repository       = "https://charts.jenkins.io"
  namespace        = kubernetes_namespace.jenkins-ns.metadata.0.name
  create_namespace = true
  values = [<<EOF
controller:
  jenkinsUriPrefix: "/jenkins"
  ingress: 
    annotations:
      apiVersion: networking.k8s.io/v1
      cert-manager.io/cluster-issuer: "${local.cluster_issuer_name}"
      cert-manager.io/duration: 2160h
      cert-manager.io/renew-before: 360h
      external-dns.alpha.kubernetes.io/hostname: "${local.full_dns}"
      kubernetes.io/ingress.allow-http: "false"
      kubernetes.io/ingress.class: traefik
      traefik.ingress.kubernetes.io/router.tls: "true"
    enabled: true
    path: /jenkins
    tls:
      - hosts: 
          - ${local.full_dns}
        secretName: jenkins-tls
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
<<<<<<< HEAD
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
    helm_release.cm,
    helm_release.external-dns
  ]
}
