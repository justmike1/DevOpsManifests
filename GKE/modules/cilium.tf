resource "helm_release" "cilium-cni" {
  name         = "cilium"
  chart        = "cilium"
  version      = "1.12.2"
  repository   = "https://helm.cilium.io/"
  namespace    = "kube-system"
  reuse_values = true

  set {
    name  = "nodeinit.enabled"
    value = true
  }
  set {
    name  = "nodeinit.reconfigureKubelet"
    value = true
  }
  set {
    name  = "nodeinit.removeCbrBridge"
    value = true
  }
  set {
    name  = "cni.binPath"
    value = "/home/kubernetes/bin"
  }
  set {
    name  = "hubble.relay.enabled"
    value = true
  }
  set {
    name  = "hubble.ui.enabled"
    value = true
  }
  set {
    name  = "gke.enabled"
    value = true
  }
  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }
  set {
    name  = "ipv4NativeRoutingCIDR"
    value = "10.48.0.0/14"
  }

  depends_on = [
    module.gke
  ]
}
