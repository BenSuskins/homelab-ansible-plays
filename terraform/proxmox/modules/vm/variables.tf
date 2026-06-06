variable "name" {
  description = "VM name (hostname)"
  type        = string
}

variable "vm_id" {
  description = "Numeric Proxmox VM ID"
  type        = number
}

variable "node_name" {
  description = "Proxmox node the VM is created on"
  type        = string
}

variable "clone_template_id" {
  description = "VM ID of the cloud-init template to clone from"
  type        = number
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Dedicated memory in MiB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Primary disk size in GiB"
  type        = number
  default     = 20
}

variable "datastore_id" {
  description = "Datastore for the VM disk, e.g. local-lvm"
  type        = string
  default     = "local-lvm"
}

variable "bridge" {
  description = "Network bridge for the primary NIC"
  type        = string
  default     = "vmbr0"
}

variable "ip_address" {
  description = "Static IPv4 address in CIDR notation for cloud-init, e.g. 192.168.0.110/24. Use \"dhcp\" for DHCP."
  type        = string
}

variable "gateway" {
  description = "IPv4 gateway for cloud-init (ignored when ip_address is \"dhcp\")"
  type        = string
  default     = "192.168.0.1"
}

variable "ssh_public_keys" {
  description = "List of SSH public keys to inject via cloud-init"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the VM"
  type        = list(string)
  default     = ["terraform"]
}
