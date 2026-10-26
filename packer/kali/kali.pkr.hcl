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

source "proxmox-iso" "kali" {
  proxmox_url = var.proxmox_url
  username    = var.proxmox_username
  token       = var.proxmox_token
  node        = var.proxmox_node

  vm_name              = var.template_name
  template_name        = var.template_name
  template_description = "Kali Linux template provisioned with Ansible"
  os                   = "l26"
  cores                = 2
  memory               = 4096
  scsi_controller      = "virtio-scsi-single"
  qemu_agent           = true
  cloud_init           = false # Enable only after configuring cloud-init in Kali guest.

  boot_iso {
    iso_file     = var.iso_file
    iso_checksum = var.iso_checksum
    unmount      = true
  }

  disks {
    type         = "scsi"
    storage_pool = var.storage_pool
    disk_size    = "40G"
  }

  network_adapters {
    model  = "virtio"
    bridge = var.network_bridge
  }

  # TODO: Add Kali/Debian unattended installer (e.g. preseed) and matching
  # boot_command. Installer must authorize the SSH key for ssh_username.
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = "30m"
}

build {
  sources = ["source.proxmox-iso.kali"]

  provisioner "ansible" {
    playbook_file = "${path.root}/../../ansible/playbooks/kali.yml"
  }
}
