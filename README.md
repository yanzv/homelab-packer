# Proxmox template builder

Separate Packer ISO templates for **Ubuntu**, **Kali Linux**, and **OPNsense**. These are **scaffolds, not build-ready installers**: each OS still needs a version-specific unattended installation and reachable SSH before any `packer build`.

## Layout

- `packer/ubuntu/`: Ubuntu source and inputs; use autoinstall, then the Linux base Ansible playbook.
- `packer/kali/`: Kali source and inputs; use the installer automation appropriate for your Kali release, then the Kali Ansible playbook.
- `packer/opnsense/`: OPNsense (FreeBSD-based) source and inputs, with distinct WAN/LAN bridge inputs. **No Linux Ansible role or cloud-init** is applied. Decide on an OPNsense-supported package/plugin provisioning method after selecting a version.
- `ansible/playbooks/template.yml`: Ubuntu provisioning entry point.
- `ansible/playbooks/kali.yml`: Kali provisioning entry point (no assumed cloud-init package).
- `ansible/roles/template_base/`: reusable Linux software role; extend with OS-specific roles as needed.

## Prepare one OS

1. Install Packer and Ansible. Run `packer init packer/<os>` for the selected OS (`ubuntu`, `kali`, or `opnsense`). A CD image tool such as `xorriso` may be needed for installer seed CDs.
2. Select a release and installer ISO and verify its checksum. Add its unattended installer and matching boot command in `packer/<os>/<os>.pkr.hcl`. It must establish SSH/key access for Packer. For OPNsense, plan the management IP, WAN/LAN assignment and supported software provisioning independently; firewall network defaults should not be assumed safe.
3. Copy `packer/<os>/example.pkrvars.hcl` to `packer/<os>/local.auto.pkrvars.hcl` (ignored by Git), then set ISO/checksum, storage, bridges and SSH values. Set `PKR_VAR_proxmox_url`, `PKR_VAR_proxmox_username`, `PKR_VAR_proxmox_token` through a secret store. Token identities use `user@realm!tokenid`. **Never commit credentials, installer password hashes, private keys, or sensitive seed files.**
4. Once the installer and access are actually wired up, run `packer validate -var-file=packer/<os>/local.auto.pkrvars.hcl packer/<os>`, then `packer build -var-file=packer/<os>/local.auto.pkrvars.hcl packer/<os>`. Check the build machine can reach the guest via SSH, and use only the Proxmox permissions necessary.

The Linux role installs `template_packages` using the guest package manager. Ubuntu defaults to `qemu-guest-agent` and `cloud-init`; Kali overrides this to `qemu-guest-agent` and `curl`. Configure cloud-init inside an Ubuntu guest before using the resulting template. OPNsense currently has **no Ansible provisioner**; the generic Linux role is inappropriate for it.

No remote Git repository, credentials, infrastructure changes, or template builds are included.
