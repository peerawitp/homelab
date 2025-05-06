variable "vm_id" {
  description = "The ID of the VM within Proxmox."
  type        = number
}

variable "vm_name" {
  description = "The name of the VM within Proxmox."
  type        = string
}

variable "target_node" {
  description = "The name of the Proxmox node on which to place the VM"
  type        = string
}

variable "description" {
  description = "A description of the VM."
  type        = string
}

variable "on_boot" {
  description = "The action to take when the VM boots. True to start the VM when node is available."
  type        = bool
}

variable "memory" {
  description = "The amount of memory to allocate to the VM."
  type        = number
}

variable "sockets" {
  description = "The number of sockets to allocate to the VM."
  type        = number
  default     = 1
}

variable "cores" {
  description = "The number of cores per CPU to allocate to the VM."
  type        = number
  default     = 1
}

variable "cpu_type" {
  description = "The type of CPU to allocate to the VM."
  type        = string
  default     = "host"
}

variable "os_type" {
  description = "Which provisioning method to use, based on the OS type."
  type        = string
}

variable "ciuser" {
  description = "Override the default cloud-init user for provisioning."
  type        = string
}

variable "cipassword" {
  description = "Override the default cloud-init password for provisioning."
  type        = string
}

variable "ciupgrade" {
  description = "Override the default cloud-init upgrade setting for provisioning."
  type        = bool
  default     = true
}

variable "disk_size" {
  description = "Size of the disk in GB."
  type        = string
}

variable "storage_name" {
  description = "Name of the storage to allocate to the VM."
  type        = string
}
