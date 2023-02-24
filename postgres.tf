###############################################################################
# Create a namespace for the database
###############################################################################
/*resource "kubernetes_namespace" "postgres" {
    metadata {
        name = "postgres"
    }
    depends_on = [
      kind_cluster.default
    ]
}*/
resource "kubernetes_secret" "db_password" {
    metadata {
        name = "${var.cluster_name}-db-password"
    }
    data = {
        password = "${var.db_password}"
    }
    type = "Opaque"
}

module "postgresql" {
  source        = "ballj/postgresql/kubernetes"
  name          = "keycloak"
  version       = "~> 1.0"
  namespace     = "default" #"${kubernetes_namespace.postgres.metadata.0.name}"
  object_prefix = "${var.cluster_name}-keycloak-db"
  username      = "keycloak"
  labels        = {
    "app.kubernetes.io/part-of" = var.cluster_name
    "name" = var.cluster_name
  }
  security_context_uid = 501 # set to UID of whatever user is running your container system
  pvc_name      = "${kubernetes_persistent_volume_claim.db_pvc.metadata.0.name}"
  image_tag     = "15.1.0-debian-11-r6"
  #service_type  = "NodePort"
  #env_secret    = [{name = "${var.cluster_name}-keycloak-db", key = "POSTGRES_PASSWORD", secret = "${var.db_password}"}] 
  depends_on    = [
    kubernetes_persistent_volume.db_pv,
    kubernetes_persistent_volume_claim.db_pvc
  ]
  password_secret = length(var.db_password) > 0 ? kubernetes_secret.db_password.metadata[0].name : ""
}

###############################################################################
# Persistant volume definitions
###############################################################################
resource "kubernetes_persistent_volume" "db_pv" {
    metadata {
        name = var.db_pvc_name
    }
    spec {
        capacity = {
            storage = "${var.pg_persistentVolumeSize}Gi"
        }
        access_modes = ["ReadWriteOnce"]
        persistent_volume_source {
            host_path {
                path = "/var/kind"
                type = "Directory"
            }
        }
        persistent_volume_reclaim_policy = "Retain"
        storage_class_name = "standard"
    }
    depends_on = [
      kind_cluster.default
    ]
}
###############################################################################
# This is the persistent
###############################################################################
resource "kubernetes_persistent_volume_claim" "db_pvc" {
    metadata {
        name = var.db_pvc_name
        namespace = "default" #"${kubernetes_namespace.postgres.metadata.0.name}"
    }
    spec {
        access_modes = ["ReadWriteOnce"]
        resources {
            requests = {
                storage = "${var.pg_persistentVolumeSize}Gi"
            }
        }
        volume_name = "${kubernetes_persistent_volume.db_pv.metadata.0.name}"
        storage_class_name = "standard"
    }
    wait_until_bound = true
    depends_on = [
        kubernetes_persistent_volume.db_pv
    ]
}