locals {
  ns_name = var.namespace != "" ? var.namespace : "${var.name_prefix}-ns"
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name   = local.ns_name
    labels = var.labels
  }
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = "${var.name_prefix}-app"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = { app = "${var.name_prefix}-app" }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = "${var.name_prefix}-app" }
    }

    template {
      metadata {
        labels = { app = "${var.name_prefix}-app" }
      }

      spec {
        container {
          name  = "app"
          image = var.image

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "250m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name      = "${var.name_prefix}-svc"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    selector = { app = "${var.name_prefix}-app" }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}
