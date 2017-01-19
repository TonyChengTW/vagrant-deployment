# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

conf = {}

require 'yaml'
conf_path = ENV.fetch('USER_CONF','config.yaml')
if File.file?(conf_path)
    user_conf = YAML.load_file(conf_path)
    conf.update(user_conf)
else
    raise "Configuration file #{conf_path} does not exist."
end

def config_vb_network(vm, conf)
    # this will be the endpoint
    vm.network :private_network, ip: conf['internal1_ip'], :netmask => conf['internal1_netmask']
    # this will be the OpenStack "public" network ip and subnet mask
    # should match floating_ip_range var in devstack.yml
    vm.network :private_network, ip: conf['external1_ip'], :netmask => conf['external1_netmask'], :auto_config => false
    vm.network :forwarded_port, guest: conf['vm_forward_port'], host: conf['host_forward_port']
end

def config_vb_provider(vm, conf)
    vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", conf['vm_memory']]
        vb.customize ["modifyvm", :id, "--cpus", conf['vm_cpus']]
       	# eth2 must be in promiscuous mode for floating IPs to be accessible
       	vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    end
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

def config_lv_define(vm, conf)
    #vm.define :conf['box_hostname'] do |libvirtos|
  vm.define :devstack1 do |centos7|
    centos7.vm.box = conf['box_name']
    centos7.vm.network :public_network,
                                ip: conf['libvirt_ip'],
                                :netmask => conf['libvirt_netmask'],
                                :gateway => conf['libvirt_gateway'],
                                :mac => conf['libvirt_mac'],
                                :dev => conf['libvirt_dev'],
                                :type => conf['libvirt_type'],
                                :mode => conf['libvirt_mode']
    centos7.vm.provider :libvirt do |domain|
      domain.memory = conf['vm_memory']
      domain.cpus = conf['vm_cpus']
      domain.management_network_name = 'vagrant-libvirt-mgmt'
      domain.management_network_address = conf['libvirt_mgmt_ip']
      domain.management_network_mode = conf['libvirt_mgmt_mode']
    end
  end
end

def config_provision(vm, conf)
    vm.provision :ansible do |ansible|
        ansible.host_key_checking = false
        ansible.playbook = "ansible/playbook.yml"
        ansible.verbose = "vv"
        #ansible.extra_vars = {}
    end
    vm.provision :shell, :inline => "cd /opt/devstack; sudo -u ubuntu env HOME=/home/ubuntu ./stack.sh"
    # interface should match external_interface var in devstack.yml
    #vm.provision :shell, :inline => "ovs-vsctl add-port br-ex enp0s9"
    #vm.provision :shell, :inline => "virsh net-destroy default"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = conf['box_name']
    config.vm.box_url = conf['box_url'] if conf['box_url']
    config.vm.hostname = conf['box_hostname']

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

    if conf['provider'] == 'virtualbox'
        config_vb_network(config.vm, conf)
        config_vb_provider(config.vm, conf)
    end

    if conf['provider'] == 'libvirt'
        config_lv_provider(config.vm, conf)
        config_lv_define(config.vm, conf)
    end
    #config_provision(config.vm, conf)

    if conf['local_sync_folder']
        config.vm.synced_folder conf['local_sync_folder'], "/opt"
    end
end

