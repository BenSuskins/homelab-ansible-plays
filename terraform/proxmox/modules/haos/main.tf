terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

# Proxmox forbids non-root users (incl. API tokens) from attaching a "real"
# USB device directly (`usb0: host=<id>` returns HTTP 500). A cluster resource
# mapping is the supported escape hatch: it's referenced by name, so the VM no
# longer pins a real device and the token can attach it. The token still needs
# Mapping.Modify on /mapping/usb to create this and Mapping.Use to attach it.
resource "proxmox_hardware_mapping_usb" "this" {
  name = "${var.name}-zigbee"

  map = [
    {
      id   = var.usb_device_id
      node = var.node_name
      path = var.usb_device_path
    },
  ]
}

# Home Assistant OS is an appliance image, not a cloud-init Debian clone:
# the disk is imported from a prepared qcow2, there is no SSH user, and it
# needs an explicit EFI disk plus USB passthrough for the radio coordinator.
resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  description = var.description
  vm_id       = var.vm_id
  node_name   = var.node_name
  tags        = var.tags

  bios          = "ovmf"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-pci"

  on_boot = var.on_boot
  started = var.started

  # HAOS ships the QEMU guest agent, so this populates ipv4_addresses.
  agent {
    enabled = true
  }

  dynamic "startup" {
    for_each = var.startup_order == null ? [] : [1]
    content {
      order = var.startup_order
    }
  }

  cpu {
    cores   = var.cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = var.memory
  }

  efi_disk {
    datastore_id      = var.datastore_id
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = false
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    import_from  = var.haos_image_file_id
    size         = var.disk_size
    ssd          = true
    discard      = "on"
    cache        = "writethrough"
  }

  network_device {
    bridge      = var.bridge
    model       = "virtio"
    mac_address = var.mac_address
  }

  usb {
    mapping = proxmox_hardware_mapping_usb.this.name
    usb3    = false
  }

  # The image is imported once; a later HAOS version bump must not try to
  # re-import over the live disk (HAOS updates itself in-place).
  lifecycle {
    ignore_changes = [disk[0].import_from]
  }
}
