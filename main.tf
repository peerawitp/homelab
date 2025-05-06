terraform {
  required_version = ">= 1.11"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_ignore_tls
}

module "pve-vm" {
  source      = "./modules/pve-vm"
  target_node = "jawvis-home"

  vm_id   = 200
  vm_name = "vm-test"

  description = "Test VM"

  memory  = 2048
  on_boot = true
  os_type = "cloud-init"

  storage_name = "local-lvm"
  disk_size    = 10

  ciuser     = "ubuntu"
  cipassword = "test"
}
