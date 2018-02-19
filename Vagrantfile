# -*- mode: ruby -*-
# vi: set ft=ruby :
#
#
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define :unix, autostart: true do |c|
    c.vm.box = "ubuntu/xenial64"
    c.vm.hostname = 'src'

    c.vm.network "private_network", ip: "192.168.42.10"
    # c.vm.network "forwarded_port", guest: 80, host: 8001

    c.ssh.forward_agent = true

    c.vm.provider "virtualbox" do |vb|
      vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    end

    c.vm.synced_folder ".", "/src"

    c.vm.provision 'shell', inline: '/bin/bash -c "cd /src; ./provision.sh"'
  end
end
