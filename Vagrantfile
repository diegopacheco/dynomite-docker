# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.network "private_network", ip: "55.55.55.100"

  config.vm.provision "shell", inline: <<-SHELL
     sudo apt-get update
     sudo apt-get install -y curl
     sudo apt-get install -y git
     sudo apt-get install -y lxc
     sudo apt-get install -y wget

     sudo add-apt-repository -y ppa:webupd8team/java
     sudo apt-get update
     sudo apt-get -y upgrade
     echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections 
     echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
     sudo apt-get -y install oracle-java8-installer	
 
     sudo wget -qO- https://get.docker.com/ | sudo bash
     git clone https://github.com/diegopacheco/dynomite-docker.git
     cd dynomite-docker/ && ./dynomite-docker.sh bake
  SHELL

end
