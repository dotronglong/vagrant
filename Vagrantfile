# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.provision "shell", inline: <<-SHELL
    cp -pr /vagrant/provision.sh /usr/bin/provision
  SHELL

  config.vm.define "lamp" do |lamp|
    lamp.vm.hostname = 'lamp'
    lamp.vm.network :private_network, ip: "192.168.33.11"
    lamp.vm.provision "shell", inline: <<-SHELL
      provision setup
      provision install_nfsd
      provision install_httpd
      provision install_mariadb
      provision install_php
      provision install_phpmyadmin
      provision install_composer
      provision install_node
      provision install_bower
      provision install_gulp
      provision info "DONE!!!"
    SHELL
  end

  config.vm.define "lemp" do |lemp|
    lemp.vm.hostname = 'lemp'
    lemp.vm.network :private_network, ip: "192.168.33.22"
    lemp.vm.provision "shell", inline: <<-SHELL
      provision setup
      provision install_nfsd
      provision install_nginx
      provision install_mariadb
      provision install_fpm
      provision install_nginx_phpmyadmin
      provision install_composer
      provision install_node
      provision install_bower
      provision install_gulp
      provision info "DONE!!!"
    SHELL
  end

  config.vm.define "buddy-ci" do |lemp|
    lemp.vm.hostname = 'buddy-ci'
    lemp.vm.network :private_network, ip: "192.168.33.88"
    lemp.vm.provision "shell", inline: <<-SHELL
      provision setup
      provision install_docker_ce
      provision install_docker_compose
      # provision install_buddy_ci
      provision info "DONE!!!"
    SHELL
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end
  end

  config.vm.define "gocd" do |lemp|
    lemp.vm.hostname = 'gocd'
    lemp.vm.network :private_network, ip: "192.168.33.90"
    lemp.vm.provision "shell", inline: <<-SHELL
      provision setup
      provision install_jre
      provision install_gocd_server
      provision install_gocd_client
      provision install_gocd_nginx
      provision info "DONE!!!"
      provision warn "PLEASE RELOAD MACHINE BEFORE USING!"
    SHELL
  end
end
