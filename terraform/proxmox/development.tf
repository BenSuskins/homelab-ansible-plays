module "development" {
  source          = "./modules/vm"
  name            = "development"
  vm_id           = 204
  node_name       = var.proxmox_node
  cores           = 4
  memory          = 3072
  memory_floating = 2048
  disk_size       = 64
  ip_address      = "192.168.0.204/24"
  ssh_public_keys = [trimspace(file("~/.ssh/homelab.pub"))]
  description     = "Development"
  startup_order   = 4
  # up_delay gates the NEXT guest in boot order (mediaserver, order 5):
  # hold 240s after this VM so the NAS is online before mediaserver mounts it.
  startup_up_delay = 240
}
