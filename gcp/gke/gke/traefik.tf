resource "kubernetes_namespace" "ingress-ns" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "ingress-controller" {
  name             = "traefik"
  chart            = "traefik"
  version          = "16.1.0"
  repository       = "https://helm.traefik.io/traefik"
  namespace        = kubernetes_namespace.ingress-ns.metadata.0.name
  create_namespace = true
  values = [<<EOF
  additionalArguments:
    - --entryPoints.web.http.redirections.entryPoint.to: websecure
    - --entryPoints.web.http.redirections.entryPoint.scheme: https
  securityContext:
    capabilities:
      drop: [ALL]
      add: [NET_BIND_SERVICE]
    readOnlyRootFilesystem: true
    runAsGroup: 0
    runAsNonRoot: false
    runAsUser: 0
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
    name  = "providers.kubernetesIngress.ingressClass"
    value = "traefik"
  }
  set {
    name  = "providers.kubernetesIngress.ingressEndpoint.publishedService"
    value = "${kubernetes_namespace.ingress-ns.metadata.0.name}/traefik"
  }
  set {
    name  = "providers.kubernetesIngress.publishedService.enabled"
    value = true
  }
  set {
    name  = "ports.web.port"
    value = 80
  }
  set {
    name  = "ports.websecure.port"
    value = 443
  }
  set {
    name  = "ingressRoute.dashboard.enabled"
    value = false
  }

  depends_on = [
    module.gke
  ]
}
