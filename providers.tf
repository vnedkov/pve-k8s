terraform {
  backend "s3" {}
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.0"
    }
    # Why do I need another kubernetes provider? 
    # Because kubectl does not need cluster configuration in the planning phase.
    # However it does not have all other kubernetes provider features.
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.69.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.1"
    }
    checkmate = {
      source  = "tetratelabs/checkmate"
      version = "1.8.4"
    }
  }
}

locals {
  client_certificate     = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.ca_certificate)
  client_configuration   = {
    host                   = module.talos.kube_config.kubernetes_client_configuration.host
    cluster_ca_certificate = local.cluster_ca_certificate
    client_certificate     = local.client_certificate
    client_key             = local.client_key
  }
}

provider "proxmox" {
  endpoint = var.proxmox.endpoint
  insecure = var.proxmox.insecure

  api_token = var.proxmox.api_token
  ssh {
    agent    = true
    username = var.proxmox.username
  }
}

provider "kubernetes" {
  host                   = module.talos.kube_config.kubernetes_client_configuration.host
  cluster_ca_certificate = local.cluster_ca_certificate
  client_certificate     = local.client_certificate
  client_key             = local.client_key
}

provider "kubectl" {
  host                   = module.talos.kube_config.kubernetes_client_configuration.host
  cluster_ca_certificate = local.cluster_ca_certificate
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  load_config_file       = false
}

provider "kustomization" {
  kubeconfig_raw = module.talos.kube_config.kubeconfig_raw
}

provider "helm" {
  kubernetes {
    host                   = module.talos.kube_config.kubernetes_client_configuration.host
    cluster_ca_certificate = local.cluster_ca_certificate
    client_certificate     = local.client_certificate
    client_key             = local.client_key
  }
}

provider "http" {
  
}

# Simple provider for checking the cluster availability over http
provider "checkmate" {
  # no configuration required
}