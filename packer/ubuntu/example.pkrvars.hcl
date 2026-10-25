# Copy to local.auto.pkrvars.hcl (ignored by Git) and replace placeholders.
# Supply Proxmox API values via PKR_VAR_proxmox_url,
# PKR_VAR_proxmox_username and PKR_VAR_proxmox_token instead of this file.
proxmox_node       = "YOUR_NODE"
iso_file           = "local:iso/YOUR_UBUNTU_SERVER_ISO.iso"
iso_checksum       = "sha256:REPLACE_WITH_VERIFIED_DIGEST"
storage_pool       = "local-lvm"
network_bridge     = "vmbr0"
template_name      = "ubuntu-template"
ssh_username       = "packer"
ssh_private_key_file = "/path/outside/repo/to/build-key"
