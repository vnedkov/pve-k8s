# pve-k8s
## Kubernetes cluster on PVE
This repository contains terraform code to deploy a Talos Kubernetes cluster on a [Proxmox Virtual Environment](https://www.proxmox.com/en/proxmox-virtual-environment/overview)

## Considerations
In order to install Cilium, CNI must not be defined in the cluster. That prevents it from reaching a "healthy" state, after which we can run Helm deployments. To avoid that chicken and egg problem Cilium is added as part of Talos machine config, as suggested [here](https://www.talos.dev/v1.9/kubernetes-guides/network/deploying-cilium/)

## Variables

## Before applying

## Creating the cluster
To create the cluster, run
```
terraform apply
```
After completion copy configuration files in your home directory
```
cp output/kube-config.yaml  ~/.kube/config
cp output/talos-config.yaml ~/.talos/config
```
Now you can first check Talos dashboard. Wait until the status is Ready
```
talosctl dashboard
```
You can also check cilium status with
```
cilium status --wait
```

## Post-deployment steps

## Destroying the cluster
To skip any health checks preventing destroying an unhealthy cluster, run:
```
terraform destroy -var 'skip_on_destroy=true'
```

## Other thoughts
### Why Talos? 
Talos is an immutable OS, allowing configuration only through cli and API
### Why Cilium? 
Cilium provides policy based control over internal networking in a Kubernetes cluster, IPAM, loadbalancing and recently - Gateway API (L7 networking). I need a descriptive way to deploy my services in my lab.


## Credits
* Thanks to Vegard S. Hagen for creating this [guide](https://blog.stonegarden.dev/articles/2024/08/talos-proxmox-tofu/#the-top)