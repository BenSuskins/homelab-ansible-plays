module "mediaserver" {
  source            = "./modules/vm"
  name              = "mediaserver"
  vm_id             = 201
  node_name         = var.proxmox_node
  clone_template_id = 9000
  cores             = 4
  memory            = 8192
  memory_floating   = 4096
  disk_size         = 64
  ip_address        = "192.168.0.201/24"
  ssh_public_keys   = [file("~/.ssh/homelab.pub")]
  description       = "Media Server"
  bios              = "ovmf"
  started           = true

  # Boots last so the NAS has time to come up first; the 240s gap is set as
  # development's up_delay (the preceding guest), since Proxmox up_delay
  # applies before the NEXT guest starts.
  startup_order = 5
}

output "mediaserver_ipv4" {
  description = "IPv4 addresses reported by the mediaserver VM guest agent"
  value       = module.mediaserver.ipv4_addresses
}
