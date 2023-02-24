resource "kubernetes_deployment" "keycloak" {
    depends_on = [
      module.postgresql
    ]
    metadata {
		name = "${var.cluster_name}-keycloak"
        labels = merge(local.labels_list)
	}
    spec {
        replicas = 1
        selector {
            match_labels = local.labels_list
        }
        template {
            metadata {
                labels = merge( local.labels_list, 
                                {"component" = "keycloak"})
            }
            spec {
                container {
                    name = "keycloak"
                    image = "${var.keycloak_image_base}:${var.keycloak_image_tag}"
                    args = ["start-dev"]
                    resources {
                        limits = {
                            cpu = var.resources_limits_cpu
                            memory = var.resources_limits_memory
                        }
                        requests = {
                            cpu = var.resources_requests_cpu
                            memory = var.resources_requests_memory
                        }
                    }
                    port {
                        name            = "http"
                        protocol        = "TCP"
                        container_port  = kubernetes_service.keycloak.spec[0].port[0].target_port
                    }
                    env {
                        name = "KEYCLOAK_ADMIN"
                        value = "admin"
                    }
                    env {
                        name = "KEYCLOAK_ADMIN_PASSWORD"
                        value = "admin"
                    }
                    env {
                        name = "KC_PROXY"
                        value = "edge"
                    }
                    env {
                        name = "KC_DB_URL_HOST"
                        value = module.postgresql.hostname
                    }
                    env {
                        name = "KC_DB_URL_PORT"
                        value = module.postgresql.port
                    }
                    env {
                        name = "KC_DB"
                        value = "postgres"
                    }
                    env {
                        name = "KC_DB_USERNAME"
                        value = module.postgresql.username
                    }
                    env {
                        name = "KC_DB_PASSWORD"
                        value_from { 
                            secret_key_ref {
                                name = length(var.db_password) > 0 ? kubernetes_secret.db_password.metadata[0].name : ""
                                key = "password"
                            }
                        } 
                    }
                    readiness_probe {
                        http_get {
                            path = "/realms/master"
                            port = kubernetes_service.keycloak.spec[0].port[0].target_port
                        }
                    }

                }
            }
        }
    }
}

resource "kubernetes_service" "keycloak" {
    metadata {
        name        = "${var.cluster_name}-keycloak"
        namespace   = var.namespace
        labels      = merge( local.labels_list,
                             {"component" = "service"}
                            )
    }
    spec {
        selector    = local.labels_list
        port {
            name        = "http"
            protocol    = "TCP"
            target_port = 8080
            port        = var.service_port
        }
    }
}