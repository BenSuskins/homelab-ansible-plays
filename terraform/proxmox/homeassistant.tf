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
  usb_device_id = "1a86:55d4"

  # TODO: set after uploading the unxz'd HAOS qcow2 to the node, e.g.
  # "local:iso/haos_ova-16.0.qcow2". bpg cannot decompress the .xz HAOS ships.
  haos_image_file_id = "local:iso/haos_ova.qcow2"

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
