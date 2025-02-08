variable "proxmox" {
  type = object({
    name         = string
    cluster_name = string
    endpoint     = string
    insecure     = bool
    username     = string
    api_token    = string
  })
  sensitive = true
}

variable "image" {
  description = "Talos image configuration"
  type = object({
    version   = string
    arch = optional(string, "amd64")
    platform = optional(string, "nocloud")
    proxmox_datastore = optional(string, "local")
    extensions = optional(list(string))
  })
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name            = string
    endpoint        = string
    gateway         = string
    talos_version   = string
    proxmox_cluster = string
  })
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node     = string
    machine_type  = string
    datastore_id  = optional(string, "local-lvm")
    ip            = string
    cidr_prefix   = optional(number, 24)
    mac_address   = string
    vm_id         = number
    cpu           = number
    ram           = number
    update        = optional(bool, false)
    igpu          = optional(bool, false)
    disk_size     = optional(number, 20)
    additional_disks = optional(list(object({
      size         = optional(number) # Size of new disks in GB
      datastore_id = optional(string, "local-lvm")
      format       = optional(string, "raw")
      iothread     = optional(bool, true)
      cache        = optional(string, "writethrough")
      discard      = optional(string, "on")
      ssd          = optional(bool, true)
      path_in_datastore = optional(string, "")
    })), )
  }))
}

variable "skip_on_destroy" {
  description = "Whether a data or a resource should be skipped on destroy. Useful for health checks. Otherwise, use lifecycle attribute."
  type = bool
  default = false
}
