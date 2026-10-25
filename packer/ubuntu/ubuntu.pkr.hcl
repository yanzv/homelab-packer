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

source "proxmox-iso" "ubuntu" {
  proxmox_url = var.proxmox_url
  username    = var.proxmox_username
  token       = var.proxmox_token
  node        = var.proxmox_node

  vm_name              = var.template_name
  template_name        = var.template_name
  template_description = "Ubuntu template provisioned with Ansible"
  os                   = "l26"
  cores                = 2
  memory               = 2048
  scsi_controller      = "virtio-scsi-single"
  qemu_agent           = true
  cloud_init           = true
  cloud_init_disable_upgrade_packages = true

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

  network_adapters {
    model  = "virtio"
    bridge = var.network_bridge
  }

  # TODO: Add Ubuntu autoinstall seed and boot_command here. The installed
  # guest must create ssh_username and authorize ssh_private_key_file's key.
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = "30m"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "ansible" {
    playbook_file = "${path.root}/../../ansible/playbooks/template.yml"
  }
}
