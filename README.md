# Proxmox template builder

Packer builds Proxmox VM templates from OS ISOs; Ansible installs software in the guest before conversion to a template. This is a **starter scaffold**, not a ready-to-build OS installer: add unattended installation and SSH access for each OS before building.

## Layout

- `packer/ubuntu/`: Ubuntu ISO build scaffold. Give each additional OS its own Packer directory (`packer/debian/`, etc.) so installer/boot settings remain independent.
- `ansible/playbooks/template.yml`: guest software provisioning entry point.
- `ansible/roles/template_base/`: small, reusable Linux base role. Extend with roles for your software.

## Prepare an OS

1. Install Packer, the Proxmox Packer plugin (`packer init packer/ubuntu`), Ansible, and a CD image tool such as `xorriso` if using seed CDs.
2. Add an unattended installer for the chosen OS (for Ubuntu, autoinstall `user-data`/`meta-data` and a matching boot command). It must create the SSH account/key used by Packer. **Do not commit credentials, password hashes, private keys, or installer files containing them.** Keep sensitive seed content outside Git.
3. Copy `packer/ubuntu/example.pkrvars.hcl` to a local ignored `.auto.pkrvars.hcl`, set ISO/checksum, storage, network, and SSH public configuration. Provide `PKR_VAR_proxmox_url`, `PKR_VAR_proxmox_username`, and `PKR_VAR_proxmox_token` from your secret store. The username for token auth includes `!tokenid`.
4. Add the OS boot/installer wiring in `packer/ubuntu/ubuntu.pkr.hcl`. The current source definition deliberately has **no boot command or unattended installer**, so do not run a build as-is.
5. When ready, run `packer validate -var-file=packer/ubuntu/local.auto.pkrvars.hcl packer/ubuntu` then `packer build -var-file=packer/ubuntu/local.auto.pkrvars.hcl packer/ubuntu`. Check the build machine can reach the guest over SSH and that the Proxmox token has only the permissions needed for building templates.

The Ansible role uses the guest's package manager (`ansible.builtin.package`) and defaults to `qemu-guest-agent` and `cloud-init`. Set `template_packages` per OS or add application-specific roles in the playbook. Cloud-init is enabled as a Proxmox template drive in the example Packer source; configure the guest image appropriately before use.

No remote Git repository, Proxmox credentials, infrastructure changes, or template builds are included.
