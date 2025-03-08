packer {
  required_version = "~> 1.8"
  required_plugins {
    vagrant = {
      version = "~> 1.1"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

locals {
  timestamp = formatdate("YYYYMMDD", timestamp())
  version   = "${var.version}.${local.timestamp}"
}

variable "box_tag" {
  type = string
}

variable "box_version" {
  type = string
}

variable "source_path" {
  type = string
}

variable "version" {
  type = string
}

variable "version_description" {
  type = string
}

source "vagrant" "almalinux" {
  box_version        = "${var.box_version}"
  communicator       = "ssh"
  template           = "Vagrantfile.tmpl"
  output_vagrantfile = "Vagrantfile"
  provider           = "vmware_desktop"
  source_path        = "${var.source_path}"
  skip_add           = true
  teardown_method    = "destroy"
}

build {
  sources = ["source.vagrant.almalinux"]

  provisioner "file" {
    destination = "/tmp"
    source      = "../provisioners"
  }

  provisioner "shell" {
    environment_vars = ["is_packer=true"]
    inline           = ["sudo -E bash -c /tmp/provisioners/script/install_system_dependencies.sh"]
    max_retries      = "3"
  }

  provisioner "shell" {
    environment_vars = ["is_packer=true"]
    inline           = ["bash -c /tmp/provisioners/script/install_ansible.sh"]
    max_retries      = "3"
  }

  provisioner "shell" {
    execute_command = "sudo -S env {{ .Vars }} {{ .Path }}"
    max_retries     = "3"
    script          = "script/cleanup.sh"
  }

  post-processors {
    post-processor "vagrant" {
      compression_level = 9
      keep_input_artifact = true
      output = "output-almalinux/{{.BuildName}}_{{.Provider}}_{{.Architecture}}.box"
      provider_override = "vmware"
    }

    post-processor "vagrant-registry" {
      box_tag             = "${var.box_tag}"
      no_release          = true
      version             = "${local.version}"
      version_description = "${var.version_description}"
    }
  }
}
