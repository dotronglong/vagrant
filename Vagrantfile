# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.provision "shell", inline: <<-SHELL
    cp -pr /vagrant/provision.sh /usr/bin/provision
  SHELL

  config.vm.define "lamp" do |box|
    box.vm.hostname = 'lamp'
    box.vm.network :private_network, ip: "192.168.33.11"
    box.vm.provision "shell", inline: <<-SHELL
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

  config.vm.define "lemp" do |box|
    box.vm.hostname = 'lemp'
    box.vm.network :private_network, ip: "192.168.33.22"
    box.vm.provision "shell", inline: <<-SHELL
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

  config.vm.define "buddy-ci" do |box|
    box.vm.hostname = 'buddy-ci'
    box.vm.network :private_network, ip: "192.168.33.88"
    box.vm.provision "shell", inline: <<-SHELL
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

  config.vm.define "gocd" do |box|
    box.vm.hostname = 'gocd'
    box.vm.network :private_network, ip: "192.168.33.90"
    box.vm.provision "shell", inline: <<-SHELL
      provision setup
      provision install_jre
      provision install_gocd_server
      provision install_gocd_client
      provision install_gocd_nginx
      provision info "DONE!!!"
    SHELL
  end

  config.vm.define "jenkins" do |box|
    box.vm.hostname = 'jenkins'
    box.vm.network :private_network, ip: "192.168.33.99"
    box.vm.provision "shell", inline: <<-SHELL
      provision setup
      provision install_jre
      provision install_jenkins
      provision install_jenkins_nginx
      provision info "DONE!!!"
    SHELL
  end

  config.vm.define "jenkins-docker" do |box|
    box.vm.hostname = 'jenkins-docker'
    box.vm.network :private_network, ip: "192.168.33.99"
    box.vm.provision "shell", inline: <<-SHELL
      provision setup
      provision install_jre
      provision install_jenkins
      provision install_jenkins_nginx
      provision install_docker_ce
      provision install_docker_compose
      usermod -aG docker jenkins
      provision info "DONE!!!"
    SHELL
  end

  config.vm.define "jenkins-php" do |box|
    box.vm.hostname = 'jenkins-php'
    box.vm.network :private_network, ip: "192.168.33.99"
    box.vm.provision "shell", inline: <<-SHELL
      provision setup
      provision install_jre
      provision install_jenkins
      provision install_jenkins_nginx
      provision install_php
      provision info "DONE!!!"
    SHELL
  end
end
