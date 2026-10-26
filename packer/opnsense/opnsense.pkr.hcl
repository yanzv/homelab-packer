packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">= 1.2.0"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.0.0"
    }
  }
}

source "proxmox-iso" "opnsense" {
  proxmox_url = var.proxmox_url
  username    = var.proxmox_username
  token       = var.proxmox_token
  node        = var.proxmox_node

  vm_name              = var.template_name
  template_name        = var.template_name
  template_description = "OPNsense firewall template (installer pending)"
  os                   = "other" # FreeBSD-based appliance, not a Linux guest.
  cores                = 2
  memory               = 4096
  scsi_controller      = "virtio-scsi-single"
  qemu_agent           = false # Enable only if the guest agent is configured.
  cloud_init           = false # Do not assume OPNsense cloud-init support.

  boot_iso {
    iso_file     = var.iso_file
    iso_checksum = var.iso_checksum
    unmount      = true
  }

  disks {
    type         = "scsi"
    storage_pool = var.storage_pool
    disk_size    = "20G"
  }

  # Dedicated bridge inputs; ensure WAN/LAN assignment is handled in the guest.
  network_adapters {
    model  = "virtio"
    bridge = var.wan_bridge
  }
  network_adapters {
    model  = "virtio"
    bridge = var.lan_bridge
  }

  # TODO: Add version-specific unattended install/boot flow and a reliable
  # SSH endpoint. qemu_agent=false usually requires an explicit ssh_host.
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_host             = var.ssh_host
  ssh_timeout          = "30m"
}

build {
  sources = ["source.proxmox-iso.opnsense"]

  # Requires installer-created SSH account with a real /bin/sh shell and
  # administrative privileges; do not reuse the Linux package role.
  provisioner "ansible" {
    playbook_file = "${path.root}/../../ansible/playbooks/opnsense.yml"
  }
}
