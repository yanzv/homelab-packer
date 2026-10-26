# Copy to local.auto.pkrvars.hcl (ignored by Git); replace placeholders.
# Supply PKR_VAR_proxmox_url, PKR_VAR_proxmox_username and
# PKR_VAR_proxmox_token and PKR_VAR_installer_password_hash
# from your secret store, not this file.
proxmox_node         = "YOUR_NODE"
iso_file             = "local:iso/YOUR_KALI_INSTALLER_ISO.iso"
iso_checksum         = "sha256:REPLACE_WITH_VERIFIED_DIGEST"
storage_pool         = "local-lvm"
network_bridge       = "vmbr0"
template_name        = "kali-template"
ssh_username         = "packer"
ssh_private_key_file = "/path/outside/repo/to/build-key"
ssh_public_key_file  = "/path/outside/repo/to/build-key.pub"
