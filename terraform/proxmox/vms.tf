# New Proxmox VMs are declared here using the ./modules/vm module.
#
# To add a VM, copy the block below, uncomment it, and adjust the values.
# Each VM clones an existing cloud-init template (clone_template_id) and gets
# a static IP in the 192.168.0.0/24 LAN via cloud-init. cloud-init creates the
# login user (username, defaults to name) with the SSH key and passwordless
# sudo, so the host is ready for `ansible-playbook plays/setup.yml`.
#
# module "example_vm" {
#   source            = "./modules/vm"
#   name              = "example"
#   username          = "example"     # Ansible ansible_user; defaults to name
#   vm_id             = 110
#   node_name         = var.proxmox_node
#   clone_template_id = 9000          # VM ID of a prepared cloud-init template
#   cores             = 2
#   memory            = 2048
#   disk_size         = 20
#   datastore_id      = "local-zfs"
#   ip_address        = "192.168.0.110/24"
#   gateway           = "192.168.0.1"
#   ssh_public_keys   = [file("~/.ssh/homelab.pub")]
#   tags              = ["terraform"]
# }
