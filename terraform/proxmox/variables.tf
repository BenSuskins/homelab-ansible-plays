variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint, e.g. https://192.168.0.253:8006/"
  type        = string
  default     = "https://192.168.0.253:8006/"
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the form 'user@realm!tokenid=secret'"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Name of the Proxmox node that owns the VMs"
  type        = string
  default     = "sensible"
}
