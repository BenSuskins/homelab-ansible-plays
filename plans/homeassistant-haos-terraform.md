# Recreate Home Assistant (HAOS) VM in Terraform

## Goal
Define the Home Assistant OS VM as code in `terraform/proxmox/`, build a **fresh**
VM (`vm_id 205`, `192.168.0.205`) alongside the existing running `vm_id 101`, then
cut over by restoring an HA backup. The old `101` stays untouched until verified.

## Why this needs its own module (not `./modules/vm`)
`./modules/vm` is hardwired for the Debian flow: it `clone`s the cloud-init template
(`clone_template_id` is now required) and injects a user + SSH key via the
`initialization` (cloud-init) block. HAOS is an **appliance image**, so:
- It is **imported** from a qcow2, never cloned.
- It has **no SSH user** and ignores Proxmox cloud-init networking.
- It needs an explicit **EFI disk** and **USB passthrough** the shared module doesn't model.
- Ansible is **not involved at all** — there is no host to configure.

So we add a dedicated `terraform/proxmox/modules/haos/` module + a `homeassistant.tf`
root file, mirroring the per-VM-file convention.

## Source-of-truth hardware (from VM 101)
| Setting | Value |
|---|---|
| BIOS | OVMF (UEFI) + 4M EFI disk, pre-enrolled keys OFF |
| Machine | q35 |
| SCSI controller | VirtIO SCSI |
| Disk | scsi0, 32G, `ssd=1`, `discard=on`, `cache=writethrough`, on `local-zfs` |
| CPU | 2 cores / 1 socket, `host` |
| Memory | 2048 MiB (fixed, no ballooning) |
| NIC | virtio on vmbr0 |
| USB | Zigbee/Z-Wave coordinator — pin **by vendor:product ID** |

## Decisions locked in
- **Image delivery: manual prep.** bpg `download_file` decompresses gz/lzo/zst/bz2
  but **not xz**; HAOS only ships `.qcow2.xz`. So we download + `unxz` once and
  upload to Proxmox storage; Terraform imports that qcow2 via `disk.import_from`.
- **USB: by vendor:product ID** (survives re-plugging) — `1a86:55d4`, the CH9102
  serial chip in the Sonoff ZBDongle-E (Zigbee 3.0 Dongle Plus V2).
- **Identity: vm_id 205, 192.168.0.205.** MAC is **auto-assigned** (HAOS ignores
  cloud-init static IPs, unlike the Debian VMs); read the `homeassistant_mac`
  output after apply and add a DHCP reservation for it → `.205`.
- **Values are inlined** in `homeassistant.tf` (matching the per-VM file
  convention), not routed through root variables. Only the image path is a
  placeholder to fill in.

## Prerequisites (manual, before `terraform apply`)
1. **HA backup**: Settings → System → Backups → create + download a full backup.
2. **Prep the HAOS image on the `pve` node** (pick the current HAOS release version):
   ```bash
   cd /var/lib/vz/template/iso
   wget https://github.com/home-assistant/operating-system/releases/download/<VER>/haos_ova-<VER>.qcow2.xz
   unxz haos_ova-<VER>.qcow2.xz
   ```
   Confirm the resulting file is importable (PVE "import" content / a path
   `import_from` can read). Record the exact file ID/path → `haos_image_file_id`.
   This is the only value still to fill into `homeassistant.tf` (`haos_image_file_id`).
3. USB ID is already known and inlined: `1a86:55d4` (Sonoff ZBDongle-E).
4. MAC is auto-assigned by Proxmox — no need to pick one. After the first apply,
   read the `homeassistant_mac` output and add a DHCP reservation for it → `.205`.

## Files to add
### `terraform/proxmox/modules/haos/main.tf`
`proxmox_virtual_environment_vm "this"` with:
- `bios = "ovmf"`, `machine = "q35"`, `scsi_hardware = "virtio-scsi-pci"`
- `agent { enabled = true }` (HAOS ships the guest agent → populates ipv4 output)
- `cpu { cores=var.cores, type="host" }`, `memory { dedicated=var.memory }`
- `efi_disk { datastore_id=var.datastore_id, type="4m", file_format="raw", pre_enrolled_keys=false }`
- `disk { datastore_id, interface="scsi0", import_from=var.haos_image_file_id, size=var.disk_size, ssd=true, discard="on", cache="writethrough" }`
  - **Gotcha**: provider defaults qcow2 import size to 8G if unset — set `size=32` explicitly.
- `network_device { bridge="vmbr0", model="virtio", mac_address=var.mac_address }`
- `usb { host=var.usb_device_id, usb3=false }`
- `lifecycle { ignore_changes = [disk[0].import_from] }` so a later image version
  bump doesn't try to re-import over the live disk.

### `terraform/proxmox/modules/haos/{variables,outputs}.tf`
Vars: name, vm_id, node_name, cores(=2), memory(=2048), disk_size(=32),
datastore_id(="local-zfs"), bridge(="vmbr0"), mac_address, usb_device_id,
haos_image_file_id, description, tags, on_boot, started, startup_order.
Output: `ipv4_addresses`.

### `terraform/proxmox/homeassistant.tf`
`module "homeassistant"` wiring the above (vm_id 205, the pinned MAC, the two
prerequisite IDs) + `output "homeassistant_ipv4"`.

### `terraform/proxmox/homeassistant.tf` (values inlined)
USB ID and disk/cpu/mem are literals; MAC omitted (auto). `haos_image_file_id`
is the one placeholder to set after image prep. No root variables added —
matches the inline convention of the other per-VM files.

## Cutover runbook (after apply)
1. `terraform apply` → VM 205 boots HAOS (dongle **not** yet attached if 101 holds it —
   USB can only bind to one running VM at a time).
2. Browse to `http://192.168.0.205:8123` → onboarding → **Restore from backup** → upload.
3. Short maintenance window: **stop 101** (frees the dongle) → start/confirm 205 grabs it →
   verify Zigbee/Z-Wave devices report in.
4. Verify automations/integrations, then decommission 101 manually (101 is **not**
   in TF state, so deleting it is a Proxmox action, not `terraform destroy`).
5. Read `terraform output homeassistant_mac` and add a DHCP reservation for it → `.205`.

## Follow-ups / watch-outs
- **`home-assistant` MCP**: its configured HA URL likely points at 101's current IP.
  After cutover, update the MCP endpoint to `.205`. The long-lived token is restored
  with the backup, so it should keep working.
- HA is intentionally **absent from the Ansible inventory** and the `docker_services`
  discovery — no change there. (Optionally add a `static_services` Homepage tile later;
  out of scope here.)
- Known HAOS-on-Proxmox boot snag: if it drops to UEFI shell, the `pre_enrolled_keys=false`
  EFI disk is the fix we've already specified.
## Open input still required from you
- `haos_image_file_id` in `homeassistant.tf` (after image prep, step 2)
