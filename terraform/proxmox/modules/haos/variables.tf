variable "name" {
  description = "VM name (hostname)"
  type        = string
  default     = "homeassistant"
}

variable "vm_id" {
  description = "Numeric Proxmox VM ID"
  type        = number
}

variable "node_name" {
  description = "Proxmox node the VM is created on"
  type        = string
}

variable "haos_image_file_id" {
  description = "File ID / path of the prepared (decompressed) HAOS qcow2 to import, e.g. local:iso/haos_ova-15.0.qcow2. Must be unxz'd first; bpg cannot decompress .xz."
  type        = string
}

variable "usb_device_id" {
  description = "Radio coordinator USB device pinned by vendor:product, e.g. 10c4:ea60 (from `lsusb` on the node)."
  type        = string
}

variable "mac_address" {
  description = "MAC for the NIC. null lets Proxmox auto-assign one; read the mac_address output and add a matching DHCP reservation for a stable IP (HAOS ignores cloud-init networking)."
  type        = string
  default     = null
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
  description = "Primary disk size in GiB. Set explicitly: the provider defaults qcow2 imports to 8G."
  type        = number
  default     = 32
}

variable "datastore_id" {
  description = "Datastore for the VM disk and EFI disk"
  type        = string
  default     = "local-zfs"
}

variable "bridge" {
  description = "Network bridge for the NIC"
  type        = string
  default     = "vmbr0"
}

variable "description" {
  description = "Free-text description shown in the Proxmox UI"
  type        = string
  default     = "Home Assistant OS"
}

variable "tags" {
  description = "Tags applied to the VM"
  type        = list(string)
  default     = ["terraform"]
}

variable "on_boot" {
  description = "Start the VM automatically when the node boots"
  type        = bool
  default     = true
}

variable "started" {
  description = "Whether the VM should be running"
  type        = bool
  default     = true
}

variable "startup_order" {
  description = "Boot/shutdown order. When null, no startup config is set."
  type        = number
  default     = null
}
