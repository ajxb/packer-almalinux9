# Ansible Sandbox

## Description

Packer templates and Vagrant machine that provides an AlmaLinux 9 machine with Ansible pre-installed.

The included scripts can be used to build the base box and provision a machine.

## Contains

* Ansible 11.3.0

## Requires

* [Vagrant](https://www.vagrantup.com/)
* [Vagrant Plugin vagrant-vmware-desktop](https://github.com/hashicorp/vagrant-vmware-desktop)
* [VMware Fusion / Workstation](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)

### Optional Requirements

* [Packer](https://www.packer.io/) - used to package base box from templates
* [Vagrant plugin vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) on Linux and macOS - used to update the hosts file automatically

## Verified Working With

* packer 1.12.0
* vagrant 2.4.3, with plugins
  * vagrant-hostmanager 1.8.10
  * vagrant-vmware-desktop 3.0.4
* VMware Fusion 13.6.2

## Usage

A justfile has been provided to wrap all essential functions, but you can use vagrant commands directly if required.

The following commands are wrapped in the justfile

- `destroy` - stops and deletes all traces of the vagrant machine
- `halt` - stops the vagrant machine
- `reload` - restarts vagrant machine, loads new Vagrantfile configuration
- `ssh` - connects to machine via SSH
- `ssh-config` - outputs OpenSSH valid configuration to connect to the machine
- `status` - outputs status of the vagrant machine
- `up` - starts and provisions the vagrant environment

To bring up a fresh instance of the Vagrant machine run:

```bash
just up
```

You can pass command parameters using the `PARAMS` justfile variable, e.g.

```bash
just PARAMS=--provision reload
```

## Packer templates for AlmaLinux 9

### Overview

This repository also contains Packer templates for creating the base box used by Vagrant.

These templates use the official AlmaLinux Vagrant machines, documented at <https://wiki.almalinux.org/installation/vagrant-boxes.html>

They can be found in the packer folder.

### Current Boxes

64-bit boxes:

* [Ansible - AlmaLinux 9](https://portal.cloud.hashicorp.com/vagrant/discover/ajxb/almalinux9)

### Building the Vagrant boxes with Packer

To build all the boxes, you will need [Packer](http://packer.io/downloads.html), [Vagrant](https://www.vagrantup.com), and [VMware Fusion / Workstation](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion). Version compatibility is as documented above.

We make use of hcl files containing user variables to build specific versions of the base box. You tell `packer` to use a specific user variable file via the `-var-file=` command line option.  This will override the default options on the core `almalinux.pkr.hcl` packer template.

For example, to build AlmaLinux 9, use the following:

```bash
packer build -var-file=almalinux9.pkr.hcl almalinux.pkr.hcl
```

### Building the Vagrant boxes with the justfile

We've also provided a justfile for ease of use, so alternatively, you can use the following to build AlmaLinux 9 for all providers:

```bash
just build
```

To release to HashiCorp Atlas use the release target:

```bash
just release
```

### Updating to a different source box

#### AlmaLinux

Details for each version of AlmaLinux can be found at https://wiki.almalinux.org/installation/vagrant-boxes.html
