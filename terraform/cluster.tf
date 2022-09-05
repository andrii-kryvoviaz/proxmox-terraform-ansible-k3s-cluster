resource "proxmox_vm_qemu" "k3s_cluster" {
  for_each = { for x in var.cluster_nodes : x.vmid => x }

  name        = each.value.name
  vmid        = each.value.vmid
  target_node = each.value.pve_node
  clone       = each.value.pve_template
  sockets     = 1
  cores       = each.value.cores
  cpu         = "host"
  memory      = each.value.memory
  agent       = 1

  # cloud-init
  os_type    = "cloud-init"
  ciuser     = "k3s"
  sshkeys    = var.ssh_public_key
  nameserver = var.nameserver
  ipconfig0  = "ip=${each.value.ip}/24,gw=${var.gateway_ip}"

  lifecycle {
    ignore_changes = [
      disk,
      network
    ]
  }
}

data "template_file" "k3s" {
  template = file("./k3s-hosts.tpl")
  vars = {
    k3s_master_ips = "${join("\n", [for instance in var.cluster_nodes : join("", [instance.ip, " ansible_ssh_private_key_file=", var.ssh_private_key_path, " ansible_user=k3s"]) if instance.is_master])}"
    k3s_node_ips   = "${join("\n", [for instance in var.cluster_nodes : join("", [instance.ip, " ansible_ssh_private_key_file=", var.ssh_private_key_path, " ansible_user=k3s"]) if !instance.is_master])}"
  }
}

resource "local_file" "k3s_file" {
  content  = data.template_file.k3s.rendered
  filename = "../ansible/inventory/k3s-cluster/hosts.ini"
}

resource "local_file" "var_file" {
  source   = "../ansible/inventory/sample/group_vars/all.yml"
  filename = "../ansible/inventory/k3s-cluster/group_vars/all.yml"
}
