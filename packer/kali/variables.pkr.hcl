variable "proxmox_url" {
  type = string
}
variable "proxmox_username" {
  type = string
}
variable "proxmox_token" {
  type      = string
  sensitive = true
}
variable "proxmox_node" {
  type = string
}
variable "iso_file" {
  type = string
}
variable "iso_checksum" {
  type = string
}
variable "storage_pool" {
  type = string
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
  type = string
}
variable "ssh_public_key_file" {
  type = string
}
variable "installer_password_hash" {
  type      = string
  sensitive = true
}
