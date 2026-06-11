module "development" {
  source            = "./modules/vm"
  name              = "development"
  vm_id             = 204
  node_name         = var.proxmox_node
  clone_template_id = 9000
  cores             = 2
  memory            = 2048
  memory_floating   = 1024
  disk_size         = 64
  ip_address        = "192.168.0.204/24"
  ssh_public_keys   = [file("~/.ssh/homelab.pub")]
  description       = "Development"
  bios              = "ovmf"
  startup_order     = 4
  started           = false
  # up_delay gates the NEXT guest in boot order (mediaserver, order 5):
  # hold 240s after this VM so the NAS is online before mediaserver mounts it.
  startup_up_delay = 240
}

output "development_ipv4" {
  description = "IPv4 addresses reported by the development VM guest agent"
  value       = module.development.ipv4_addresses
}
