variable "kube_config_path" {
    type = string
    default = "~/.kube/config"
    description = "This is the location of the kubernetes configuration file that should be used"
}

variable "cluster_name" {
    type = string
    default = "sitc"
    description = "This is the name of the Kind cluster that will be created. This will be appended to 'kind-'."
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for deployment"
  default = "default"
}

variable "pg_hostPath" {
    type = string
    default = ""
    description = "This is the directory on the host machine where the postgres data will be stored"
    nullable = false
}

variable "pg_containerPath" {
    type = string
    default = ""
    description = "This is the mount point within the node on which the pg_hostPath directory will mounted for use by the postgres pod"
    nullable = false
}

variable "pg_persistentVolumeSize" {
    type = string
    default = "2"
    description = "The size of the persistent volume used by the postgres pod"
}

variable "kind_node_image" {
    type = string
    default = "kindest/node:v1.24.6"
    description = "This is the image/version for the Kind cluster nodes. v1.24.6 is as high as we can go right now with the postgres image"
}

variable "db_pvc_name" {
    type = string
    default = "database-data-pvc"
    description = "This is the name of the Persistant Volume Claim used by the database container"
}

variable "common_labels" {
    type = map(string)
    description = "A string map of common labels to apply to all resources"
    default = {}
}

variable "keycloak_image_base" {
    type = string
    description = "The keycloak image to deploy"
    default = "quay.io/keycloak/keycloak"
}

variable "keycloak_image_tag" {
    type = string
    description = "The tag of the keycloak image to pull and deploy"
    default = "20.0.1"
}

variable "resources_requests_cpu" {
  type        = string
  description = "The maximum amount of compute resources allowed for postgres and keycloak pods"
  default     = null
}

variable "resources_requests_memory" {
  type        = string
  description = "The minimum amount of compute resources required for postgres and keycloak pods"
  default     = null
}

variable "resources_limits_cpu" {
  type        = string
  description = "The maximum amount of compute resources allowed for postgres and keycloak pods"
  default     = null
}

variable "resources_limits_memory" {
  type        = string
  description = "The minimum amount of compute resources required for postgres and keycloak pods"
  default     = null
}

variable "service_type" {
  type        = string
  description = "Service type"
  default     = "ClusterIP"
}

variable "service_port" {
  type        = number
  description = "External port for keycloak service"
  default     = 80
}

variable "db_password" {
    type = string
    default = "Ch@ng3M3!"
    description = "The default password used by the postgres db setup"
}