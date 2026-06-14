module "homeassistant" {
  source       = "./modules/haos"
  name         = "homeassistant"
  vm_id        = 205
  node_name    = var.proxmox_node
  cores        = 2
  memory       = 2048
  disk_size    = 32
  datastore_id = "local-zfs"

  # MAC is auto-assigned (HAOS ignores cloud-init static IPs, unlike the Debian
  # VMs). After the first apply, read homeassistant_mac and add a DHCP
  # reservation pointing it at 192.168.0.205.

  # Sonoff ZBDongle-E (Zigbee 3.0 Dongle Plus V2). 1a86:55d4 is its CH9102
  # USB-serial chip; don't pin a second CH340/CH9102 device the same way.
  # Attached via a cluster USB resource mapping (modules/haos/main.tf) because
  # Proxmox blocks non-root tokens from attaching real USB devices directly.
  # Set usb_device_path (e.g. "1-8.2") here if a second identical chip appears.
  usb_device_id = "1a86:55d4"

  # Unxz'd HAOS qcow2 uploaded to local:import on the node. bpg cannot
  # decompress the .xz HAOS ships, so the image is prepped manually.
  haos_image_file_id = "local:import/haos_ova-17.3.qcow2"

  description = "Home Assistant OS"
}

output "homeassistant_ipv4" {
  description = "IPv4 addresses reported by the Home Assistant VM guest agent"
  value       = module.homeassistant.ipv4_addresses
}

output "homeassistant_mac" {
  description = "Auto-assigned NIC MAC; add a DHCP reservation for it pointing at 192.168.0.205"
  value       = module.homeassistant.mac_address
}
