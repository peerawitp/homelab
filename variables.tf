variable "pm_api_url" {
  description = "This is the target Proxmox API endpoint"
  type        = string
  default     = "https://proxmox_url/api2/json"
}

variable "pm_api_token_id" {
  description = "This is the target Proxmox API endpoint"
  type        = string
}

variable "pm_api_token_secret" {
  description = "This is the target Proxmox API endpoint"
  type        = string
}

variable "pm_ignore_tls" {
  description = "Disable TLS verification while connecting"
  type        = string
  default     = "true"
}
