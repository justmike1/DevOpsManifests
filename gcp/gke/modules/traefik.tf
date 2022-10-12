resource "kubernetes_namespace" "ingress-ns" {
  metadata {
    name = "traefik-ingress-controller"
  }
}

resource "helm_release" "ingress-controller" {
  name             = "traefik"
  chart            = "traefik"
  version          = "10.30.1"
  repository       = "https://helm.traefik.io/traefik"
  namespace        = kubernetes_namespace.ingress-ns.metadata.0.name
  create_namespace = true
  values = [<<EOF
  ports:
    web:
      port: 80
    websecure:
      port: 443
  additionalArguments:
    - --entryPoints.web.http.redirections.entryPoint.to: websecure
    - --entryPoints.web.http.redirections.entryPoint.scheme: https
    - --providers.kubernetesingress
    - --providers.kubernetesingress.ingressclass=traefik
    - --providers.kubernetesIngress.ingressEndpoint.publishedService=${kubernetes_namespace.ingress-ns.metadata.0.name}/traefik
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
            - general
EOF
  ]

  depends_on = [
    module.gke
  ]
}
