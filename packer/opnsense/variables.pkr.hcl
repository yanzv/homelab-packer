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
variable "base_template_vm_id" {
  type        = number
  description = "VMID of an already installed and tested OPNsense base template"
  validation {
    condition     = var.base_template_vm_id >= 100 && var.base_template_vm_id <= 999999999
    error_message = "The base template VMID must be valid for Proxmox."
  }
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
variable "ssh_host" {
  type        = string
  description = "Reachable clone management IP during build (not the Proxmox host)"
}
