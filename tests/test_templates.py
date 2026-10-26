"""Offline Packer configuration checks (no Proxmox API or guest builds)."""

from __future__ import annotations

import ctypes
import os
from pathlib import Path
import subprocess
import unittest

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

ROOT = Path(__file__).resolve().parents[1]
PACKER = os.environ.get("PACKER_BIN", "packer")
DUMMY_ENV = {
    "PKR_VAR_proxmox_url": "https://example.invalid:8006/api2/json",
    "PKR_VAR_proxmox_username": "example@pve!test",
    "PKR_VAR_proxmox_token": "not-a-real-token",
    "PKR_VAR_installer_password_hash": "not-a-real-hash",
}


def memory_fd(name: str) -> int:
    """Keep test-only key material in memory on Linux Python builds."""
    if hasattr(os, "memfd_create"):
        return os.memfd_create(name)
    libc = ctypes.CDLL(None, use_errno=True)
    create = libc.memfd_create
    create.argtypes = [ctypes.c_char_p, ctypes.c_uint]
    create.restype = ctypes.c_int
    fd = create(name.encode(), 0)
    if fd < 0:
        raise OSError(ctypes.get_errno(), "memfd_create failed")
    return fd


class TemplateChecks(unittest.TestCase):
    def test_each_template_validates_without_real_credentials(self) -> None:
        # memfd keeps the throwaway test key off disk; it is never deployed.
        key = Ed25519PrivateKey.generate()
        private_fd = memory_fd("packer-validation-key")
        public_fd = memory_fd("packer-validation-public")
        try:
            os.write(
                private_fd,
                key.private_bytes(
                    serialization.Encoding.PEM,
                    serialization.PrivateFormat.OpenSSH,
                    serialization.NoEncryption(),
                ),
            )
            os.write(
                public_fd,
                key.public_key().public_bytes(
                    serialization.Encoding.OpenSSH,
                    serialization.PublicFormat.OpenSSH,
                ) + b"\n",
            )
            base_args = [
                f"-var=ssh_private_key_file=/proc/{os.getpid()}/fd/{private_fd}"
            ]
            for name in ("ubuntu", "kali", "opnsense"):
                with self.subTest(os=name):
                    args = [
                        PACKER,
                        "validate",
                        f"-var-file=packer/{name}/example.pkrvars.hcl",
                        *base_args,
                    ]
                    if name != "opnsense":
                        args.append(
                            f"-var=ssh_public_key_file=/proc/{os.getpid()}/fd/{public_fd}"
                        )
                    args.append(f"packer/{name}")
                    proc = subprocess.run(
                        args,
                        cwd=ROOT,
                        env={**os.environ, **DUMMY_ENV},
                        capture_output=True,
                        text=True,
                        timeout=90,
                        check=False,
                    )
                    self.assertEqual(proc.returncode, 0, proc.stderr + proc.stdout)
        finally:
            os.close(private_fd)
            os.close(public_fd)

    def test_opnsense_uses_preinstalled_base_template(self) -> None:
        source = (ROOT / "packer/opnsense/opnsense.pkr.hcl").read_text()
        self.assertIn('source "proxmox-clone" "opnsense"', source)
        self.assertIn("clone_vm_id", source)
        self.assertNotIn("boot_iso", source)


if __name__ == "__main__":
    unittest.main()
