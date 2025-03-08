# Set strict bash options
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Default box name
box := "almalinux9"

# Default recipe
default: build

# Build the box locally (skip vagrant cloud)
build: clean
    packer build --except=vagrant-cloud -var-file={{box}}.pkr.hcl almalinux.pkr.hcl

# Clean build artifacts
clean:
    rm -fr output-almalinux

# Release the box to vagrant cloud
release: clean
    packer build -force -var-file={{box}}.pkr.hcl almalinux.pkr.hcl

# Validate the packer configuration
validate:
    packer validate -var-file={{box}}.pkr.hcl almalinux.pkr.hcl

# Destroy the vagrant environment (with confirmation)
destroy: confirm
    vagrant destroy --force

# Stop the vagrant environment
halt:
    vagrant halt {{params}}

# Reload the vagrant environment
reload:
    vagrant reload {{params}}

# SSH into the vagrant environment
ssh:
    vagrant ssh {{params}}

# Show SSH configuration
ssh-config:
    vagrant ssh-config {{params}}

# Show vagrant environment status
status:
    vagrant status {{params}}

# Start the vagrant environment
up:
    vagrant up {{params}}

# Confirmation prompt with color output
confirm:
    #!/usr/bin/env bash
    if [[ -z "${CI:-}" ]]; then
        read -p "⚠ Are you sure? [y/n] > " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "\033[31m[KO]\033[0m Stopping"
            exit 1
        else
            echo -e "\033[32m[OK]\033[0m Continuing"
        fi
    fi
