variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL (https://host:8006/api2/json)"
}
variable "proxmox_username" {
  type        = string
  description = "API token identity (user@realm!tokenid)"
}
variable "proxmox_token" {
  type      = string
  sensitive = true
}
variable "proxmox_node" {
  type = string
}
variable "iso_file" {
  type        = string
  description = "Existing Proxmox ISO datastore path (storage:iso/file.iso)"
}
variable "iso_checksum" {
  type        = string
  description = "Verified ISO checksum, e.g. sha256:<digest>"
}
variable "storage_pool" {
  type = string
}
variable "iso_storage_pool" {
  type        = string
  description = "Proxmox storage accepting ISO images for the generated NoCloud CD"
}
variable "network_bridge" {
  type = string
}
variable "template_name" {
  type = string
}
variable "ssh_username" {
  type = string
}
variable "ssh_private_key_file" {
  type        = string
  description = "Path to a private key outside this repository; install corresponding public key in guest"
}
variable "ssh_public_key_file" {
  type        = string
  description = "Public key corresponding to ssh_private_key_file"
}
variable "installer_password_hash" {
  type        = string
  sensitive   = true
  description = "SHA-512 crypt hash for Ubuntu installer identity; supply via PKR_VAR_installer_password_hash"
}
