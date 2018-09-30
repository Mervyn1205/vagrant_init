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

	config.vm.provider "virtualbox" do |v|
		v.memory = 4096
		v.cpus = 2
		v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
	end

	config.vm.define "lnmp" , autostart: false do |lnmp|
		lnmp.vm.network "private_network", ip: "192.168.33.10"
		lnmp.vm.hostname = 'lnmp'
	end

	config.vm.define "lnmp2" do |lnmp2|
		lnmp2.vm.network "private_network", ip: "192.168.31.11"
		lnmp2.vm.hostname = 'lnmp2'
	end

	config.vm.define "node1" , autostart: false do |node1|
		node1.vm.network "private_network", ip: "192.168.31.12"
		node1.vm.hostname = 'node-1'
	end

end
