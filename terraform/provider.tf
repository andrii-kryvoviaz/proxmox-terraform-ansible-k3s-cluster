terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.3"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret

  # uncoment if you are using a self-signed certificate
  #pm_tls_insecure = true
}
