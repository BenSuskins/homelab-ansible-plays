output "vm_id" {
  description = "Numeric Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_addresses" {
  description = "LAN IPv4 addresses reported by the guest agent (Docker/CNI bridges and loopback filtered out via lan_ipv4_prefix)"
  value = [
    for ip in flatten(proxmox_virtual_environment_vm.this.ipv4_addresses) :
    ip if startswith(ip, var.lan_ipv4_prefix)
  ]
}

output "mac_address" {
  description = "MAC address of the primary NIC (for a DHCP reservation)"
  value       = proxmox_virtual_environment_vm.this.network_device[0].mac_address
}
