module "talos" {
  source = "github.com/vnedkov/pve-k8s-talos.git?ref=v0.0.5"

  providers = {
    proxmox = proxmox
  }

  image   = var.image
  cluster = var.cluster
  nodes   = var.nodes

  machine_config_patches = local.machine_config_patches
}
