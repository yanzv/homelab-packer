# Copy to local.auto.pkrvars.hcl (ignored by Git); replace placeholders.
# Supply PKR_VAR_proxmox_url, PKR_VAR_proxmox_username and
# PKR_VAR_proxmox_token from your secret store, not this file.
proxmox_node         = "YOUR_NODE"
base_template_vm_id  = 9000 # Existing, tested OPNsense template VMID.
template_name        = "opnsense-provisioned-template"
ssh_username         = "YOUR_PRIVILEGED_BUILD_USER"
ssh_private_key_file = "/path/outside/repo/to/build-key"
ssh_host             = "192.0.2.10" # Reachable management IP of the clone.
