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

# OPNsense's interactive installer is intentionally NOT pretended to be
# unattended here. Clone an already-installed, tested base template instead.
source "proxmox-clone" "opnsense" {
  proxmox_url  = var.proxmox_url
  username     = var.proxmox_username
  token        = var.proxmox_token
  node         = var.proxmox_node
  clone_vm_id  = var.base_template_vm_id
  full_clone   = true
  task_timeout = "10m"

  vm_name              = var.template_name
  template_name        = var.template_name
  template_description = "OPNsense cloned base, provisioned with Ansible"
  os                   = "other"
  qemu_agent           = false
  cloud_init           = false
  # No disk or NIC overrides: preserve the tested base template's storage,
  # WAN/LAN mapping, boot firmware, and firewall interface assignments.

  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_host             = var.ssh_host
  ssh_timeout          = "30m"
}

build {
  sources = ["source.proxmox-clone.opnsense"]

  # Base template must have key-based SSH to a privileged real shell.
  provisioner "ansible" {
    playbook_file = abspath("${path.root}/../../ansible/playbooks/opnsense.yml")
  }
}
