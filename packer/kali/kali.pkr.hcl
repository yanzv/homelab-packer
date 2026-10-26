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

  # Serve installer answers and the public SSH key to the guest.
  http_content = {
    "/preseed.cfg" = templatefile(abspath("${path.root}/preseed.pkrtpl"), {
      hostname       = var.template_name
      username       = var.ssh_username
      password_hash  = var.installer_password_hash
      ssh_public_key = regex("^[^ ]+ +[^ ]+", trimspace(file(var.ssh_public_key_file)))
    })
  }
  boot_wait = "10s"
  # Kali installer BIOS boot prompt; adapt the menu keystrokes if using UEFI.
  boot_command = [
    "<esc><wait>",
    "auto=true priority=critical url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ---<enter>"
  ]

  disks {
    type         = "scsi"
    storage_pool = var.storage_pool
    disk_size    = "40G"
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
  sources = ["source.proxmox-iso.kali"]

  provisioner "ansible" {
    playbook_file = abspath("${path.root}/../../ansible/playbooks/kali.yml")
  }
}
