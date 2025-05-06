terraform {
  required_version = ">= 1.11"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

resource "proxmox_lxc" "lxc_container" {
  target_node = var.target_node
  ostemplate  = var.ostemplate
  hostname    = var.hostname
  description = var.description
  cores       = var.cores
  memory      = var.memory
  onboot      = var.onboot
  start       = var.start
  network {
    name     = var.network_name
    bridge   = var.network_bridge
    ip       = var.network_ip
    gw       = var.network_gw
    firewall = var.network_firewall
  }
  nameserver   = var.nameserver
  searchdomain = var.searchdomain
  password     = var.password
  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }
  unprivileged    = var.unprivileged
  ssh_public_keys = var.ssh_public_keys
}
