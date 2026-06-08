module "bumblebee" {
  source            = "./modules/vm"
  name              = "bumblebee"
  vm_id             = 200
  node_name         = var.proxmox_node
  clone_template_id = 9000
  cores             = 2
  memory            = 2048
  disk_size         = 128
  ip_address        = "192.168.0.200/24"
  ssh_public_keys   = [file("~/.ssh/homelab.pub")]
  description       = "Github Actions Runner"
  bios              = "ovmf"
  startup_order     = 1
}

output "bumblebee_ipv4" {
  description = "IPv4 addresses reported by the bumblebee VM guest agent"
  value       = module.bumblebee.ipv4_addresses
}
