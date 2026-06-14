terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
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
    host = var.usb_device_id
    usb3 = false
  }

  # The image is imported once; a later HAOS version bump must not try to
  # re-import over the live disk (HAOS updates itself in-place).
  lifecycle {
    ignore_changes = [disk[0].import_from]
  }
}
