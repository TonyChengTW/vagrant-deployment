# DevStack in a Vagrant VM with Ansible

This repository contains a Vagrantfile and an Ansible playbook
that sets up a VirtualBox virtual machine that installs [DevStack][4].


You can configure devstack services by editing the playbook.yml file.


## Prereqs

Install the following applications on your local machine first:

 * [VirtualBox][5]
 * [Vagrant][2]
 * [Ansible][3]


## Boot the virtual machine and install DevStack

Grab this repo and do a `vagrant up`, like so:

```bash
git clone https://github.com/TonyChengTW/vagrant-fitos20
cd vagrant-fitos20
vagrant up
```
There are two nodes as behalf of compute1 and controller1

The Vagrantfile use vagrantfile-config.yaml file as default configuration.
You can define another configuration file by the following: 

The NICs of each node are:
eth0 --> vagrant management network
eth1 --> openstack management network (endpoint network)
eth2 --> openstack external network
eth3 --> ceph public & cluster
eth4 --> VM tunnel

## Horizon

* URL: http://172.20.1.11
* Username: admin or demo
* Password: password


## Allow VMs to connect to the internet (Linux hosts only)

By default, VMs started by OpenStack will not be able to connect to the
internet. If you want your VMs to connect out, and you are running Linux
as your host operating system, you must configure your host machine to do
network address translation (NAT).

To enable NAT, issue the following commands in your host, as root:

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
## Destroy VMs with vagrant command

    vagrant destroy --force && vagrant up
