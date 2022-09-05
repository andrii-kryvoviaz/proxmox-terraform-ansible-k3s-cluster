# Kubernetes cluster on Proxmox using Terraform + Ansible

This tool allows you to create a bunch of virtual machines using cloud-init and then initialize a Kubernetes cluster. Make life easier, spin up a Kubernetes cluster in a few minutes.

### Proxmox

Before you start, you need to create a cloud-init vm template on Proxmox.
But first, you need to create a cloud-init iso image. Run the following command (use any linux machine, except Proxmox itself).

Intall image tools:

```bash
apt-get install libguestfs-tools
```

Then donwload the cloud-init image ( I will use Ubuntu 22.04 LTS as an example):

```bash
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```

Add qemu-guest-agent to the image:

```bash
virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent
```

Then upload your image to Proxmox. And create a vm:

```bash
qm create 600 --name "ubuntu-jammy-cloudinit-template" --memory 2048 --net0 virtio,bridge=vmbr0
```

Then attach the cloud-init image to the vm:

```bash
qm importdisk 600 jammy-server-cloudimg-amd64.img local-lvm
qm set 600 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-600-disk-0
qm set 600 --ide2 local-lvm:cloudinit
```

Set the cloud-init image as a boot device:

```bash
qm set 600 --boot c --bootdisk scsi0
```

Update serial console settings:

```bash
qm set 600 --serial0 socket --vga serial0
```

Now log in to Proxmox, update disk size and create a template.

After that, navigate to Datacenter -> Permissionns -> API Tokens and create a new token. Copy the token and save it somewhere. You will need it later.

## Terraform

Used to create a bunch of virtual machines in Proxmox.

Navigate to the terraform directory and rename terraform.tfvars.example to terraform.tfvars. Then edit the file and set your Proxmox credentials and the token you created earlier.

Feel free to change the number of virtual machines, their names, and other settings.

Then run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## Ansible

Navigate to the ansible directory and edit /inventory/k3s-cluster/group_vars/all.yml. Adjust the settings to your needs.

Then run the following command:

```bash
ansible-playbook site.yml -i inventory/k3s-cluster/hosts.ini
```

To remove the cluster, run the following command (it won't remove the virtual machines):

```bash
ansible-playbook reset.yml -i inventory/k3s-cluster/hosts.ini
```

## Kubernetes

Copy the kubeconfig file from the master node to your local machine:

```bash
scp k3s@master-node-ip:~/.kube/config ~/.kube/config
```

Then you can use kubectl to manage your cluster.
