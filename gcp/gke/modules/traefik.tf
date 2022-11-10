resource "kubernetes_namespace" "ingress-ns" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "ingress-controller" {
  name             = "traefik"
  chart            = "traefik"
  version          = "19.0.3"
  repository       = "https://helm.traefik.io/traefik"
  namespace        = kubernetes_namespace.ingress-ns.metadata.0.name
  create_namespace = true
  values = [<<EOF
  additionalArguments:
    - --ping
    - --ping.entrypoint=web
  service:
    annotations:
      cloud.google.com/backend-config: "{\"ports\": {\"80\":\"backendconfig-${google_compute_security_policy.cluster-sec-policy.name}\"}}"
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
    name  = "ingressRoute.dashboard.enabled"
    value = false
  }
  set {
    name  = "providers.kubernetesIngress.ingressClass"
    value = "traefik"
  }
  set {
    name  = "ports.traefik.healthchecksPort"
    value = 8000
  }
  set {
    name  = "providers.kubernetesIngress.publishedService.pathOverride"
    value = "${kubernetes_namespace.ingress-ns.metadata.0.name}/traefik"
  }
  set {
    name  = "providers.kubernetesIngress.publishedService.enabled"
    value = true
  }
  set {
    name  = "ingressClass.isDefaultClass"
    value = false
  }
  set {
    name  = "ports.web.nodePort"
    value = 32080
  }
  set {
    name  = "ports.web.nodePort"
    value = 32443
  }
  set {
    name  = "service.type"
    value = "NodePort"
  }
  set {
    name  = "logs.access.enabled"
    value = false
  }
  set {
    name  = "logs.general.level"
    value = "DEBUG"
  }
  set {
    name  = "logs.access.format"
    value = "json"
  }

  depends_on = [
    module.gke
  ]
}
