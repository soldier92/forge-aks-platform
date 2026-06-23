locals {
  cleaned_team = trim(replace(replace(replace(replace(lower(var.team_name), " ", "-"), "_", "-"), "/", "-"), "\\", "-"), "-")
  cleaned_env  = trim(replace(replace(replace(replace(lower(var.environment), " ", "-"), "_", "-"), "/", "-"), "\\", "-"), "-")
  namespace    = "team-${local.cleaned_team}-${local.cleaned_env}"
  app_labels = {
    app         = var.app_name
    team        = local.cleaned_team
    environment = local.cleaned_env
  }
}

resource "kubernetes_namespace" "team" {
  metadata {
    name = local.namespace
    labels = {
      owner-team  = local.cleaned_team
      environment = local.cleaned_env
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_resource_quota" "team" {
  metadata {
    name      = "starter-quota"
    namespace = kubernetes_namespace.team.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.requested_cpu
      "requests.memory" = var.requested_memory
      "limits.cpu"      = var.requested_cpu
      "limits.memory"   = var.requested_memory
      "pods"            = "5"
    }
  }
}

resource "kubernetes_limit_range" "team" {
  metadata {
    name      = "starter-limits"
    namespace = kubernetes_namespace.team.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.requested_cpu
        memory = var.requested_memory
      }
      default_request = {
        cpu    = var.requested_cpu
        memory = var.requested_memory
      }
    }
  }
}

resource "kubernetes_service_account" "team" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace.team.metadata[0].name
  }
}

resource "kubernetes_role" "team_reader" {
  metadata {
    name      = "${var.app_name}-reader"
    namespace = kubernetes_namespace.team.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "team_reader" {
  metadata {
    name      = "${var.app_name}-reader-binding"
    namespace = kubernetes_namespace.team.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.team_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.team.metadata[0].name
    namespace = kubernetes_namespace.team.metadata[0].name
  }
}

resource "kubernetes_config_map" "team" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.team.metadata[0].name
  }

  data = {
    TEAM_NAME   = var.team_name
    ENVIRONMENT = var.environment
    APP_VERSION = var.app_version
  }
}

resource "kubernetes_deployment" "team" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.team.metadata[0].name
    labels    = local.app_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = local.app_labels
      }

      spec {
        service_account_name = kubernetes_service_account.team.metadata[0].name

        container {
          name  = var.app_name
          image = var.image

          port {
            container_port = 8000
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.team.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = var.requested_cpu
              memory = var.requested_memory
            }
            limits = {
              cpu    = var.requested_cpu
              memory = var.requested_memory
            }
          }

          security_context {
            allow_privilege_escalation = false
            run_as_non_root            = true

            capabilities {
              drop = ["ALL"]
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "team" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.team.metadata[0].name
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      port        = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_network_policy" "team" {
  metadata {
    name      = "${var.app_name}-policy"
    namespace = kubernetes_namespace.team.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = var.app_name
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      ports {
        port     = "8000"
        protocol = "TCP"
      }
    }

    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }
      }

      ports {
        port     = "53"
        protocol = "UDP"
      }

      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }
}
