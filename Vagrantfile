# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Edit by Tony Cheng 
# Email : tonycheng@cloudcube.com.tw
#

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

conf = {}

require 'yaml'
conf_path = ENV.fetch('USER_CONF','./vagrantfile-config.yaml')
if File.file?(conf_path)
    user_conf = YAML.load_file(conf_path)
    conf.update(user_conf)
else
    raise "Configuration file #{conf_path} does not exist."
end

def config_lv_provider(vm, conf)
    vm.provider :libvirt do |libvirt|
        libvirt.host = conf['libvirt_host']
        libvirt.driver = conf['libvirt_driver']
        libvirt.username = conf['libvirt_username']
        libvirt.connect_via_ssh = conf['libvirt_connect_via_ssh']
        libvirt.storage_pool_name = conf['libvirt_storage_pool_name']
        libvirt.nested = conf['libvirt_nested']
    end
end
# -----------------  Box Start -------------------------------------------------------
def config_lv_define_deployserver(vm, conf)
  vm.define conf['hostname_deployserver'] do |deployserver|
    deployserver.vm.hostname = conf['hostname_deployserver']
    deployserver.vm.box = conf['imagename_deployserver']
    deployserver.vm.network :private_network,
                                :libvirt__network_name => "mgmt",
                                :mac => conf['libvirt_mgmt_mac_deployserver'],
                                :ip => conf['libvirt_mgmt_ip_deployserver'],
                                :libvirt__netmask => conf['libvirt_mgmt_netmask_deployserver'],
                                :libvirt__dhcp_enabled => false,
                                :libvirt__forward_mode => "none"
    deployserver.vm.provider :libvirt do |domain|
      domain.memory = conf['memory_deployserver']
      domain.cpus = conf['cpus_deployserver']
      domain.management_network_name = 'vagrantmgmt'
      domain.management_network_address = conf['libvirt_vagrantmgmt_ip_deployserver']
      domain.management_network_mode = conf['libvirt_mgmt_mode']
    end
    config_provision(deployserver.vm, conf)
  end
end
#  --------------  Box End -------------------------------------------------------

#  --------------  Provision Start ----------------------------------------------------
def config_provision(vm, conf)
    vm.provision :shell, run: "always", inline: "setenforce 0"
    vm.provision :shell, run: "always", inline: "sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config"
    vm.provision :shell, run: "always", inline: "yum -y install net-tools expect"
    vm.provision :shell, run: "always", path: "setrootpasswd.sh"
    vm.provision :shell, run: "always", inline: "ifup eth1"
    vm.provision :shell, run: "always", inline: "eval `route -n|awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"
    vm.provision :shell, run: "always", inline: "sed -i 's/^#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config"
    vm.provision :shell, run: "always", inline: "sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd"
    #vm.provision :ansible do |ansible|
    #    ansible.host_key_checking = false
    #    ansible.playbook = "ansible/playbook.yml"
    #    ansible.verbose = "vv"
    #    #ansible.extra_vars = {}
    #end
    #vm.provision :shell, :inline => "cd /opt/devstack; sudo -u ubuntu env HOME=/home/ubuntu ./stack.sh"
    # interface should match external_interface var in devstack.yml
    #vm.provision :shell, :inline => "ovs-vsctl add-port br-ex enp0s9"
    #vm.provision :shell, :inline => "virsh net-destroy default"
end
#  --------------  Provision End ----------------------------------------------------

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
    end

    if Vagrant.has_plugin?("vagrant-proxyconf") && conf['proxy']
        config.proxy.http     = conf['proxy']
        config.proxy.https    = conf['proxy']
        config.proxy.no_proxy = "localhost,127.0.0.1"
    end

    # resolve "stdin: is not a tty warning", related issue and proposed 
    # fix: https://github.com/mitchellh/vagrant/issues/1673
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    config.ssh.forward_agent = true
    config_lv_provider(config.vm, conf)
    config_lv_define_deployserver(config.vm, conf)
    if conf['local_sync_folder']
        config.vm.synced_folder conf['local_sync_folder'], "/vagrant"
    end
end
