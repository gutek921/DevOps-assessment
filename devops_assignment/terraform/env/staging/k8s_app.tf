# This is only for PoC. In normal flow i will use helm chart for it and rollout or argocd.

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app"
  }
}

resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "nginx-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    "default.conf" = <<-EOT
      server {
          listen 80;
          server_name _;

          root /usr/share/nginx/html;
          index index.html;

          location / {
              try_files $uri $uri/ =404;
          }

          location /healthz {
              access_log off;
              return 200 'OK';
              add_header Content-Type text/plain;
          }
      }
    EOT
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = { app = "web" }
  }

  spec {
    replicas = 2

    selector {
      match_labels = { app = "web" }
    }

    template {
      metadata {
        labels = { app = "web" }
      }

      spec {
        service_account_name = kubernetes_service_account.app_ksa.metadata[0].name

        container {
          name  = "nginx"
          image = "nginx:1.25-alpine"

          port {
            container_port = 80
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}

# Internal L4 Load Balancer, will work only in internal network
resource "kubernetes_service" "web_internal_lb" {
  metadata {
    name      = "web-internal-lb"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = { app = "web" }

    annotations = {
      "networking.gke.io/load-balancer-type" = "Internal"
    }
  }

  spec {
    selector = { app = "web" }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}
