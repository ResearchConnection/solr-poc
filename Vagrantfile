# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  #config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network :forwarded_port, guest: 80, host: 81
  config.vm.network :forwarded_port, guest: 8983, host: 8989
  config.vm.network :forwarded_port, guest: 27017, host: 27018

end
