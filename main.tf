module "talos" {
  source = "github.com/vnedkov/pve-k8s-talos.git?ref=v0.0.1"

  providers = {
    proxmox = proxmox
  }

  image   = var.image
  cluster = var.cluster
  nodes   = var.nodes
}
