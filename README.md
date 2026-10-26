# Proxmox template builder

Separate Packer ISO builds for **Ubuntu Server**, **Kali Linux**, and **OPNsense**, with Ansible guest provisioning. These are version-sensitive starting templates. **No Proxmox build has been run or verified.** OPNsense still needs its installation and management-SSH automation before it can build unattended.

## Layout

- `packer/ubuntu/`: Ubuntu Server live-ISO GRUB boot command, NoCloud autoinstall seed, SSH-key login, and Ansible `template.yml` (qemu guest agent + cloud-init).
- `packer/kali/`: Kali installer BIOS boot command, Debian preseed served over Packer's HTTP server, SSH-key login, and Ansible `kali.yml` (qemu guest agent + curl).
- `packer/opnsense/`: OPNsense DVD ISO source, separate WAN/LAN bridges and an Ansible `raw` playbook to install `os-qemu-guest-agent`. **Installer boot/answer flow and SSH shell access remain TODO.** No Linux package role or cloud-init is used.

## Build preparation (per OS)

1. Install Packer, Ansible, and a CD image tool such as `xorriso` for Ubuntu's NoCloud seed. Run `packer init packer/<os>` for `ubuntu`, `kali`, or `opnsense`.
2. Select and verify an installer ISO checksum for the exact release. Ubuntu assumes a live server ISO with GRUB paths `/casper/vmlinuz` and `/casper/initrd`; Kali assumes an installer ISO with the BIOS boot prompt and a first disk `/dev/sda`. Adjust boot and disk settings if your release differs. Installer networking must reach Packer's host over HTTP for Kali; use an isolated build network because the preseed contains a password hash.
3. Copy `packer/<os>/example.pkrvars.hcl` to `packer/<os>/local.auto.pkrvars.hcl` (ignored by Git), and replace placeholders. Set `PKR_VAR_proxmox_url`, `PKR_VAR_proxmox_username` (`user@realm!tokenid`), and `PKR_VAR_proxmox_token` from a secret store. For Ubuntu/Kali also set `PKR_VAR_installer_password_hash` to a **unique, temporary SHA-512 crypt hash** via a secret store; do not use a real/reused account password. Point public/private SSH-key file inputs to a keypair stored outside this repo. The installer creates the `ssh_username` account.
4. OPNsense requires a version-specific unattended install/boot sequence, safe WAN/LAN assignment, reachable `ssh_host`, and an administrative account with a real shell and key auth. The Packer source does not automate those prerequisites. Confirm the OPNsense plugin is available on your chosen release before provisioning. Do not connect an unconfigured firewall template to production networks.
5. When prerequisites are met, run `packer fmt -check packer/<os>`, `packer validate -var-file=packer/<os>/local.auto.pkrvars.hcl packer/<os>`, then `packer build -var-file=packer/<os>/local.auto.pkrvars.hcl packer/<os>`. Verify the template on an isolated clone before production use, and remove/lock the temporary installer account and credentials as part of your image hardening. Packer validation alone cannot prove installer keystrokes or guest connectivity.

Do not commit credentials, password hashes, private keys, generated installer seed files, or Packer logs. Use least-privilege Proxmox API permissions. There is no Git remote or automatic production change.
