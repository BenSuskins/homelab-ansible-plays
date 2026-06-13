module "monitor" {
  source          = "./modules/vm"
  name            = "monitor"
  vm_id           = 203
  node_name       = var.proxmox_node
  cores           = 2
  memory          = 4096
  memory_floating = 2048
  disk_size       = 64
  ip_address      = "192.168.0.203/24"
  ssh_public_keys = [file("~/.ssh/homelab.pub")]
  description     = "Monitoring"
  startup_order   = 3
}

output "monitor_ipv4" {
  description = "IPv4 addresses reported by the monitor VM guest agent"
  value       = module.monitor.ipv4_addresses
}
