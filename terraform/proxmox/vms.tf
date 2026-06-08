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
#   username          = "example"        # Ansible ansible_user; defaults to name
#   vm_id             = 110
#   node_name         = var.proxmox_node
#   clone_template_id = 9000             # VM ID of the cloud-init template
#   cores             = 2
#   memory            = 2048
#   disk_size         = 64
#   datastore_id      = "local-zfs"
#   ip_address        = "192.168.0.110/24" # or "dhcp"
#   gateway           = "192.168.0.1"
#   ssh_public_keys   = [file("~/.ssh/homelab.pub")]
#   tags              = ["terraform"]
#
#   # --- Optional knobs (all have sensible defaults; shown with their defaults) ---
#   # description         = "Web server"
#   # pool_id             = "production"   # for pool-targeted backup jobs
#   # protection          = false         # block accidental destroy
#   # on_boot             = true          # start with the node
#   # started             = true
#   # agent_enabled       = true
#   #
#   # startup_order       = 1             # boot ordering (set to enable)
#   # startup_up_delay    = 30            # secs before the next VM starts
#   # startup_down_delay  = 30
#   #
#   # cpu_sockets         = 1
#   # cpu_type            = "host"
#   # cpu_numa            = false
#   # cpu_flags           = []
#   # memory_floating     = 0             # set = memory to enable ballooning
#   #
#   # bios                = "seabios"     # or "ovmf"
#   # machine             = "pc"          # or "q35"
#   # tablet_device       = true
#   #
#   # disk_ssd            = false
#   # disk_discard        = "ignore"      # "on" to pass TRIM to local-zfs
#   # disk_iothread       = false
#   # disk_cache          = "none"
#   # disk_backup         = true          # include in vzdump backups
#   # disk_replicate      = true
#   #
#   # network_model       = "virtio"
#   # vlan_id             = null
#   # network_mac_address = null          # pin for a DHCP reservation
#   # network_firewall    = false
#   # network_rate_limit  = null          # MB/s
# }

 module "bumblebee" {
   source            = "./modules/vm"
   name              = "bumblebee"
   username          = "bumblebee"        # Ansible ansible_user; defaults to name
   vm_id             = 200
   node_name         = var.proxmox_node
   clone_template_id = 9000             # VM ID of the cloud-init template
   cores             = 2
   memory            = 2048
   disk_size         = 128
   datastore_id      = "local-zfs"
   ip_address        = "192.168.0.200/24" # or "dhcp"
   gateway           = "192.168.0.1"
   ssh_public_keys   = [file("~/.ssh/homelab.pub")]
   tags              = ["terraform"]

   # --- Optional knobs (all have sensible defaults; shown with their defaults) ---
   description         = "Github Actions Runner"
   # pool_id             = "production"   # for pool-targeted backup jobs
   # protection          = false         # block accidental destroy
   on_boot             = true          # start with the node
   started             = true
   agent_enabled       = true
   #
   startup_order       = 1             # boot ordering (set to enable)
   # startup_up_delay    = 30            # secs before the next VM starts
   # startup_down_delay  = 30
   #
   # cpu_sockets         = 1
   # cpu_type            = "host"
   # cpu_numa            = false
   # cpu_flags           = []
   # memory_floating     = 0             # set = memory to enable ballooning
   #
   bios                = "ovmf"     # or "ovmf"
   machine             = "q35"          # or "q35"
   # tablet_device       = true
   #
   # disk_ssd            = false
   # disk_discard        = "ignore"      # "on" to pass TRIM to local-zfs
   # disk_iothread       = false
   # disk_cache          = "none"
   # disk_backup         = true          # include in vzdump backups
   # disk_replicate      = true
   #
   # network_model       = "virtio"
   # vlan_id             = null
   # network_mac_address = null          # pin for a DHCP reservation
   # network_firewall    = false
   # network_rate_limit  = null          # MB/s
 }