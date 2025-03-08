require 'yaml'
require Vagrant.source_root.join("plugins/commands/ssh_config/command")

ROOT = File.dirname(__FILE__)
CONF = YAML.load_file("#{ROOT}/config.yaml")

Vagrant.configure('2') do |config|
  config.vm.box = "almalinux/9"
  config.vm.box_version = "9.5.20241203"

  hostname = CONF['machine']['hostname']['name']
  hostname = Socket.gethostname.split('.').first if 'generated' == hostname
  hostname += '-' + CONF['machine']['hostname']['postfix'] if CONF['machine']['hostname']['postfix']
  hostname += '.' + CONF['machine']['hostname']['domain'] if CONF['machine']['hostname']['domain']
  config.vm.hostname = hostname
  config.vm.define hostname

  if Vagrant.has_plugin?('vagrant-hostmanager')
    config.hostmanager.enabled      = true
    config.hostmanager.manage_guest = true
    config.hostmanager.manage_host  = true
    config.hostmanager.aliases      = CONF['machine']['aliases'] if CONF['machine']['aliases']
  end

  config.vm.network :private_network, ip: CONF['machine']['ip'] if CONF['machine']['ip']

  config.vm.provider :vmware_desktop do |vb|
    vb.vmx["memsize"] = CONF['machine']['memory']
    vb.vmx["numvcpus"] = CONF['machine']['cpus']
  end

  # Add a file to indicate that this is a vagrant virtual machine
  config.vm.provision "shell", inline: "touch /etc/is_vagrant_vm"

  # Install Ansible
  config.vm.provision 'shell', inline: '/vagrant/provisioners/script/install_system_dependencies.sh'
  config.vm.provision 'shell', inline: '/vagrant/provisioners/script/install_ansible.sh', privileged: false

  # Configure SSH to make using VSCode Remote via SSH simpler
  # See https://gist.github.com/shadyvb/cd06ee086ab0f1f8e0898717a2f036f3?permalink_comment_id=5007237#gistcomment-5007237 for details
  config.trigger.after [:up, :reload] do |trigger|
    trigger.ruby do |env,machine|
      ssh_template = VagrantPlugins::CommandSSHConfig::Command.new(["--host", machine.name.to_s, machine.name.to_s], env)
      ssh_config = File.join(File.expand_path('~'), '.ssh', 'config.d', machine.name.to_s)
      $stdout = File.new(ssh_config, 'w')
      ssh_template.execute
      $stdout = STDOUT
    end
  end
  config.trigger.after [:destroy, :halt] do |trigger|
    trigger.ruby do |env,machine|
      ssh_config = File.join(File.expand_path('~'), '.ssh', 'config.d', machine.name.to_s)
      File.delete(ssh_config) if File.exist?(ssh_config)
    end
  end
end
