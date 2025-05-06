terraform {
  required_version = ">= 1.11"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  vmid        = var.vm_id
  name        = var.vm_name
  target_node = var.target_node
  desc        = var.description
  onboot      = var.on_boot
  agent       = 1 # Enable qemu-guest-agent

  clone      = "ubuntu-2404-cloudinit-tmpl"
  full_clone = true

  memory   = var.memory
  sockets  = var.sockets
  cores    = var.cores
  cpu_type = var.cpu_type
  os_type  = var.os_type

  bootdisk = "scsi0"
  scsihw   = "virtio-scsi-pci"

  ciuser     = var.ciuser
  cipassword = var.cipassword
  ciupgrade  = var.ciupgrade

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.storage_name
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = var.disk_size
          storage = var.storage_name
          discard = true
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=10.1.1.99/24,gw=10.1.1.1"
}
