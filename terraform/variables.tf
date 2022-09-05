variable "proxmox_api_url" {
  type        = string
  description = "URL of the Proxmox API"
}

variable "proxmmox_api_token_id" {
  type        = string
  sensitive   = true
  description = "Token ID for the Proxmox API"
}

variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Token secret for the Proxmox API"
}

variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "SSH public key to use for the cluster"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to the SSH private key to use for the cluster"
}

variable "nameserver" {
  type        = string
  description = "DNS server to use for the cluster"
}

variable "gateway_ip" {
  type        = string
  description = "IP address of the gateway"
}

variable "cluster_nodes" {
  description = "Virual machine parameters"

  type = list(object({
    name         = string
    ip           = string
    vmid         = number
    memory       = number
    cores        = number
    is_master    = bool
    pve_node     = string
    pve_template = string
  }))

  default = []
}
