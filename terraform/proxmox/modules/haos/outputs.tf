output "vm_id" {
  description = "Numeric Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_addresses" {
  description = "IPv4 addresses reported by the guest agent"
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses
}

output "mac_address" {
  description = "MAC address of the primary NIC (for a DHCP reservation)"
  value       = proxmox_virtual_environment_vm.this.network_device[0].mac_address
}
