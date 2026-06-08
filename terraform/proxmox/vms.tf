# Reference template for a Proxmox VM.
#
# Each real VM lives in its own file in this directory (e.g. bumblebee.tf,
# mediaserver.tf), containing its `module` block and its IP `output`. To add a
# new VM, copy the block below into a new <name>.tf file and adjust the values.
#
# Each VM clones the cloud-init template (clone_template_id) and gets a static
# IP via cloud-init. cloud-init creates the login user (username, defaults to
# name) with the SSH key and passwordless sudo, so the host is ready for
# `ansible-playbook plays/setup.yml`.
#
# module "example" {
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
#   # startup_up_delay    = 30            # secs before the NEXT guest starts
#   # startup_down_delay  = 30
#   #
#   # cpu_sockets         = 1
#   # cpu_type            = "host"
#   # cpu_numa            = false
#   # cpu_flags           = []
#   # memory_floating     = 0             # set = memory to enable ballooning
#   #
#   # bios                = "seabios"     # or "ovmf"
#   # machine             = "q35"         # or "pc"
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
#
#   # output "example_ipv4" {
#   #   value = module.example.ipv4_addresses
#   # }
# }
