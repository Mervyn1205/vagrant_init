# vagrant_init

## 安装 virtualbox

* 下载地址：https://www.virtualbox.org/wiki/Downloads
* 运行安装，完成安装后记得将默认保存路径更改到其它盘（管理-全局设定-常规-默认虚拟电脑位置）

## 安装vagrant

* 下载地址：https://www.vagrantup.com/downloads.html
* 运行安装即可

## Vagrant 初始化

已使用 ubuntu 为例
```
vagrant box add ubuntu https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box
```

执行以下命令即可
```
vagrant up
vagrant ssh lnmp
sudo bash ~/init_lnmp.sh > init_lnmp.log
```

## Vagrant 打包
```
# --base 后的名称同 virtualbox中虚拟机的名称
vagrant package --output lnmp.box --base vagrant_init_lnmp_1531188575496_7036
```

打包后需要执行以下命令，才能在Vagrantfile中引用
```
vagrant box add lnmp lnmp.box
```

## Vagrant 常用命令

```shell
$ vagrant up        # 启动虚拟机
$ vagrant halt      # 关闭虚拟机
$ vagrant reload    # 重启虚拟机
$ vagrant ssh       # SSH 至虚拟机
$ vagrant suspend   # 挂起虚拟机
$ vagrant resume    # 唤醒虚拟机
$ vagrant status    # 查看虚拟机运行状态
$ vagrant destroy   # 销毁当前虚拟机


#box管理命令
$ vagrant box list    # 查看本地box列表
$ vagrant box add     # 添加box到列表

$ vagrant box remove  # 从box列表移除 
```