# Proxmox template builder

Packer configurations for **Ubuntu Server**, **Kali Linux**, and **OPNsense**, with Ansible guest provisioning. The configurations pass offline Packer validation with dummy inputs; **no real Proxmox build or guest boot has been verified**.

## Layout

- `packer/ubuntu/`: Ubuntu live-server ISO, GRUB boot command, NoCloud autoinstall seed, SSH-key login; `ansible/playbooks/template.yml` installs qemu-guest-agent and cloud-init.
- `packer/kali/`: Kali installer ISO, BIOS boot command, Debian preseed over Packer HTTP, SSH-key login; `ansible/playbooks/kali.yml` installs qemu-guest-agent and curl.
- `packer/opnsense/`: **Proxmox clone** of an already installed/tested OPNsense base template; `ansible/playbooks/opnsense.yml` uses `raw` (no Python required) to install `os-qemu-guest-agent`. No cloud-init, disk, NIC or firmware overrides: the base template retains its WAN/LAN mapping. This deliberately avoids pretending OPNsense's interactive ISO installer is unattended.
- `tests/test_templates.py`: offline Packer validation with dummy API inputs and a throwaway in-memory SSH key.

## Inputs and build

1. Install Packer, Ansible and, for Ubuntu's NoCloud seed, an ISO authoring tool such as `xorriso`. Run `packer init packer/<os>` for each OS.
2. For Ubuntu/Kali, select and verify the installer ISO checksum for your exact release. Ubuntu assumes a live-server ISO with GRUB `/casper/vmlinuz` and `/casper/initrd`; Kali assumes a BIOS installer prompt and `/dev/sda` as its install disk. Boot keystrokes must be tested on your selected releases. Kali's installer must reach the Packer host over HTTP; keep the build on an isolated network because the preseed contains a password hash.
3. For OPNsense, first create a **separate base template** by installing OPNsense on an isolated VM. Configure and verify safe WAN/LAN interface assignment, a reachable clone management IP, key-based SSH for a privileged account with a real shell, and the target firmware/disk layout. Set `base_template_vm_id` to that template's VMID; do not point at a production firewall. Verify the OPNsense guest-agent plugin exists for your selected release.
4. Copy `packer/<os>/example.pkrvars.hcl` to `packer/<os>/local.auto.pkrvars.hcl` (ignored by Git), and replace placeholders. Set `PKR_VAR_proxmox_url`, `PKR_VAR_proxmox_username` (`user@realm!tokenid`), and `PKR_VAR_proxmox_token` via your secret manager. For Ubuntu/Kali also set `PKR_VAR_installer_password_hash` to a **unique temporary SHA-512 crypt hash** through the secret manager, never a reused password. Point SSH key paths outside this repo; the installer must authorize the matching public key. Ubuntu's `iso_storage_pool` must support ISO uploads and differs from disk `storage_pool` when using `local-lvm`.
5. From the repository root, run `packer fmt -check packer/<os>`, then `packer validate -var-file=packer/<os>/local.auto.pkrvars.hcl packer/<os>`. Once real credentials and isolated test infrastructure are ready, run `packer build -var-file=packer/<os>/local.auto.pkrvars.hcl packer/<os>`. Validate the resulting image by cloning it in isolation. Lock or remove the temporary installer account and its key as part of image hardening before production use.

Offline check: `python3 -m unittest discover -s tests -v` (Linux with `cryptography`, Packer plugins, and Ansible on PATH), plus `ansible-playbook --syntax-check -i 'localhost,' ansible/playbooks/<playbook>.yml` for each playbook. Neither test reaches Proxmox.

Never commit credentials, password hashes, private keys, generated seed files, or Packer logs. Use least-privilege Proxmox API permissions. No remote Git repository or automatic production change is configured.
