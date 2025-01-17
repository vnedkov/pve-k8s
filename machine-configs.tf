locals {
  cilium_install = file("${path.module}/manifests/cilium-install.yaml")
  cilium_config = file("${path.module}/manifests/cilium-config.yaml")
  # Create a list of machine configuration patches for each node and store all in a map
  machine_config_patches = {
    for k, v in var.nodes:
      k => [
        # Set hostname and labels for all nodes
        yamlencode({
          machine = {
            network = {
              hostname = k
            }
            nodeLabels = {
              "topology.kubernetes.io/region" = var.cluster.name,
              "topology.kubernetes.io/zone" = k
            }
          }}),
        # Enable control plane nodes to run load as workers
        yamlencode({  
          cluster = {
            allowSchedulingOnControlPlanes = true
          }
        }),
        # Install cilium on control plane nodes.
        # It necessary to install it as part of the machine configuration,
        # because the cluster will never reach a healthy state without a CNI.
        # Additional CRDs and configurations can be added later as HELM Charts.
        v.machine_type == "controlplane" ?
        yamlencode({  
          cluster = {
            network = {
              cni = {
                name = "none"
              }
            }
            proxy = {
              disabled = true
            }
            inlineManifests = [
              {
                name = "cilium-values"
                contents = local.cilium_config
              },
              {
                name = "cilium-bootstrap"
                contents = local.cilium_install
              },
            ]
          }
        }) : ""
     ]
  }
}
