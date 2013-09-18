# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "raring64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/raring/current/raring-server-cloudimg-vagrant-amd64-disk1.box"
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.synced_folder "vagrant_data", "/vagrant_data"
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    config.vm.provision :shell, :inline => File.read("dotfiles/.install/install-linux")
  end
end
