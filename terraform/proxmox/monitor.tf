module "monitor" {
  source          = "./modules/vm"
  name            = "monitor"
  vm_id           = 203
  node_name       = var.proxmox_node
  cores           = 2
  memory          = 2048
  memory_floating = 2048
  disk_size       = 64
  ip_address      = "192.168.0.203/24"
  ssh_public_keys = [trimspace(file("~/.ssh/homelab.pub"))]
  description     = "Monitoring"
  startup_order   = 3
}
