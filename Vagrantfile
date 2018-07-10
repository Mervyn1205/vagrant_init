# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

	# 统一使用 ubuntu box ， 之前应该执行过 vagrant box add ubuntu https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box
	config.vm.box = "ubuntu"
	
	# 共享文件夹映射
	config.vm.synced_folder "E:/workspace", "/workspace"
	
	config.vm.provision "file", source: "./sources.list", destination: "/tmp/sources.list"
	config.vm.provision "file", source: "./lnmp/nginx.conf", destination: "/tmp/nginx.conf"
	config.vm.provision "file", source: "./lnmp/localhost.conf", destination: "/tmp/localhost.conf"
	config.vm.provision "file", source: "./lnmp/php-fpm.conf", destination: "/tmp/php-fpm.conf"
	config.vm.provision "file", source: "./lnmp/init_lnmp.sh", destination: "~/init_lnmp.sh"
	
	config.vm.define "lnmp" do |lnmp|
		lnmp.vm.network "private_network", ip: "192.168.33.10"
		lnmp.vm.hostname = 'lnmp'
	end
	
	config.vm.define "node1" , autostart: false do |node1|
		node1.vm.network "private_network", ip: "192.168.31.11"
		node1.vm.hostname = 'node-1'
	end
	
	config.vm.define "node2" , autostart: false do |node2|
		node2.vm.network "private_network", ip: "192.168.31.12"
		node2.vm.hostname = 'node-2'
	end
	
	config.vm.define "node3" , autostart: false do |node3|
		node3.vm.network "private_network", ip: "192.168.31.13"
		node3.vm.hostname = 'node-2'
	end

end
