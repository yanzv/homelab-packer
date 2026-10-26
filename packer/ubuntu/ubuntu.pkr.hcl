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

  vm_name                             = var.template_name
  template_name                       = var.template_name
  template_description                = "Ubuntu template provisioned with Ansible"
  os                                  = "l26"
  cores                               = 2
  memory                              = 2048
  scsi_controller                     = "virtio-scsi-single"
  qemu_agent                          = true
  cloud_init                          = true
  cloud_init_disable_upgrade_packages = true

  boot_iso {
    iso_file     = var.iso_file
    iso_checksum = var.iso_checksum
    unmount      = true
  }

  # NoCloud seed is generated locally; do not commit actual credentials.
  additional_iso_files {
    cd_label         = "cidata"
    iso_storage_pool = var.iso_storage_pool
    cd_content = {
      "meta-data" = "instance-id: ubuntu-packer\nlocal-hostname: ubuntu-template\n"
      "user-data" = templatefile(abspath("${path.root}/user-data.pkrtpl"), {
        hostname       = var.template_name
        username       = var.ssh_username
        password_hash  = var.installer_password_hash
        ssh_public_key = trimspace(file(var.ssh_public_key_file))
      })
    }
    unmount = true
  }

  # Ubuntu Server live ISO with GRUB (check menu/paths for selected release).
  boot_wait = "10s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz autoinstall ---<enter>",
    "initrd /casper/initrd<enter>",
    "boot<enter>"
  ]

  disks {
    type         = "scsi"
    storage_pool = var.storage_pool
    disk_size    = "20G"
  }

  network_adapters {
    model  = "virtio"
    bridge = var.network_bridge
  }

  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = "30m"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "ansible" {
    playbook_file = abspath("${path.root}/../../ansible/playbooks/template.yml")
  }
}
