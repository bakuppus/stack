resource "helm_release" "consul" {
  depends_on = ["kubernetes_cluster_role_binding.tiller"]

  name         = "consul"
  chart        = "${path.module}/helm-charts/consul-helm-0.5.0"
  timeout      = 300
  force_update = true

  set {
    name  = "version"
    value = "0.7.0"
  }

  set {
    name  = "global.image"
    value = "consul:1.4.0"
  }

  set {
    name  = "global.imageK8S"
    value = "nicholasjackson/consul-k8s:latest"
  }

  set {
    name  = "ui.enabled"
    value = true
  }

  set {
    name  = "syncCatalog.enabled"
    value = false
  }

  set {
    name  = "connectInject.enabled"
    value = true
  }

  set {
    name  = "client.grpc"
    value = true
  }

  set {
    name  = "client.enabled"
    value = true
  }

  set {
    name  = "server.enabled"
    value = true
  }

  set {
    name  = "dns.enabled"
    value = true
  }
}
