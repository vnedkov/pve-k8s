data "http" "io_gatewayclasses" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml"
}
data "http" "io_gateways" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml"
}
data "http" "io_httproutes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml"
}
data "http" "io_referencegrants" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml"
}
data "http" "io_grpcroutes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml"
}
data "http" "io_tlsroutes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml"
}
data "http" "io_tcproutes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
}

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

        # Longhorn
        # https://longhorn.io/docs/1.6.0/advanced-resources/os-distro-specific/talos-linux-support/
        yamlencode({  
          machine = {
            kubelet = {
              extraMounts = [
                {
                  source =  "/var/lib/longhorn",
                  destination = "/var/lib/longhorn",
                  type = "bind",
                  options = [ "bind", "rshared", "rw" ]
                }
              ]
            }
          },
          cluster = {
            apiServer = {
              admissionControl = [{
                name = "PodSecurity",
                configuration = {
                  exemptions = {
                    # kube-system will be added by the default manifest
                    namespaces = ["longhorn-system"]
                  }
                }
              }]
            }
          }
        }),
  
        # Install cilium on control plane nodes.
        # It necessary to install it as part of the machine configuration,
        # because the cluster will never reach a healthy state without a CNI.
        # Additional CRDs and configurations can be added later as HELM Charts.
        # https://www.talos.dev/v1.9/kubernetes-guides/network/deploying-cilium/#method-5-using-a-job
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
              # Gateway CRDs - see https://github.com/cilium/cilium/issues/33239 to understand why this is necessary before cluster creation
              {
                name = "io_gatewayclasses"
                contents = data.http.io_gatewayclasses.body
              },
              {
                name = "io_gateways"
                contents = data.http.io_gateways.body
              },
              {
                name = "io_httproutes"
                contents = data.http.io_httproutes.body
              },
              {
                name = "io_referencegrants"
                contents = data.http.io_referencegrants.body
              },
              {
                name = "io_grpcroutes"
                contents = data.http.io_grpcroutes.body
              },
              {
                name = "io_tlsroutes"
                contents = data.http.io_tlsroutes.body
              },
              {
                name = "io_tcproutes"
                contents = data.http.io_tcproutes.body
              },
              # Cilium installation
              {
                name = "cilium-values"
                contents = local.cilium_config
              },
              {
                name = "cilium-install"
                contents = local.cilium_install
              },
            ]
          }
        }) : ""
     ]
  }
}
