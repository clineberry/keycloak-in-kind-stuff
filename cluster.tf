locals {
    labels_list = merge({"app" = var.cluster_name},
                        var.common_labels)
}

resource "kind_cluster" "default" {
    name = var.cluster_name
    kubeconfig_path = local.kube_config_path
    #wait_for_ready = true

    kind_config {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"

        node {
            role = "control-plane"
            image = var.kind_node_image
            kubeadm_config_patches = [
                "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
            ]
            extra_port_mappings {
                container_port = 80
                host_port = 80
                protocol = "TCP"
            }
            extra_port_mappings {
                container_port = 443
                host_port = 443
                protocol = "TCP"
            }
        }
        node {
            role = "worker"
            image = var.kind_node_image

            extra_mounts {
                host_path       = var.pg_hostPath
                container_path  = var.pg_containerPath
            }
        }
    }
}
