# Copy to local.auto.pkrvars.hcl (ignored by Git); replace placeholders.
# Supply PKR_VAR_proxmox_url, PKR_VAR_proxmox_username and
# PKR_VAR_proxmox_token from your secret store, not this file.
proxmox_node         = "YOUR_NODE"
iso_file             = "local:iso/YOUR_OPNSENSE_DVD_ISO.iso"
iso_checksum         = "sha256:REPLACE_WITH_VERIFIED_DIGEST"
storage_pool         = "local-lvm"
wan_bridge           = "vmbr0"
lan_bridge           = "vmbr1"
template_name        = "opnsense-template"
ssh_username         = "YOUR_BUILD_USER"
ssh_private_key_file = "/path/outside/repo/to/build-key"
ssh_host             = "192.0.2.10" # Replace with reachable build guest IP.
