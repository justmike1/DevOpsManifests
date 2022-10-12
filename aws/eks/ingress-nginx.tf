resource "helm_release" "nginx-ingress-internal" {
  name             = "ingress-nginx-internal"
  chart            = "ingress-nginx"
  version          = "4.2.5"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  namespace        = "ingress"
  create_namespace = true
  values = [<<EOF
controller:
  admissionWebhooks:
    enabled: false
  replicaCount: 1
  metrics:
    enabled: "true"
  ingressClassByName: true
  ingressClassResource:
    name: nginx-internal
    controllerValue: "k8s.io/nginx-internal"
  config:
    use-forwarded-headers: "true"
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-internal: "true"
      service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '3600'
    externalTrafficPolicy: Local
    targetPorts:
        https: https
        http: http
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - ingress-nginx
          - key: app.kubernetes.io/instance
            operator: In
            values:
            - ingress-nginx-internal
          - key: app.kubernetes.io/component
            operator: In
            values:
            - controller
        topologyKey: "kubernetes.io/hostname"
EOF
  ]
  depends_on = [
    module.eks
  ]
}
