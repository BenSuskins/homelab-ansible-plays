module "docker" {
  source          = "./modules/vm"
  name            = "docker"
  vm_id           = 202
  node_name       = var.proxmox_node
  cores           = 2
  memory          = 4096
  memory_floating = 2048
  disk_size       = 64
  ip_address      = "192.168.0.202/24"
  ssh_public_keys = [file("~/.ssh/homelab.pub")]
  description     = "Docker Host"
  startup_order   = 2
}

output "docker_ipv4" {
  description = "IPv4 addresses reported by the docker VM guest agent"
  value       = module.docker.ipv4_addresses
}
