
locals {
    kube_config_path = pathexpand(var.kube_config_path)
}

terraform {
    required_providers {
        kind = {
            source  = "tehcyx/kind"
            version = "0.0.16"
        }
        minikube = {
            source = "scott-the-programmer/minikube"
            version = "0.0.6"
        }
    }
}

            #source = "unicell/kind"
            #version = "0.0.2-u2"

provider "kind" {}

provider "kubernetes" {
    config_path = local.kube_config_path
    #config_context = "sitc"
}

provider "minikube" {
  # Configuration options
  kubernetes_version = "v1.24.6"
}