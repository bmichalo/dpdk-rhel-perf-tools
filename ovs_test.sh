#!/bin/bash


# using "rpm"
ovs_bin="/usr/bin"
ovs_sbin="/usr/sbin"
ovs_run="/var/run/openvswitch"
ovs_etc="/etc/openvswitch"

# completely kill and remove old ovs configuration
killall -q -w ovs-vswitchd
killall -q -w ovsdb-server
killall -q -w ovsdb-server ovs-vswitchd
rm -rf $ovs_run/ovs-vswitchd.pid
rm -rf $ovs_run/ovsdb-server.pid
rm -rf $ovs_etc/*db*


# OVS switch configuration

DB_SOCK="$ovs_run/db.sock"
mkdir -p $ovs_run
mkdir -p $ovs_etc
# Initializing the OVS configuration database at $ovs_etc/conf.db using 'ovsdb-tool create'...
$ovs_bin/ovsdb-tool create $ovs_etc/conf.db /usr/share/openvswitch/vswitch.ovsschema

# Starting the OVS configuration database process ovsdb-server and connecting to Unix socket $DB_SOCK...
$ovs_sbin/ovsdb-server -v --remote=punix:$DB_SOCK \
	--remote=db:Open_vSwitch,Open_vSwitch,manager_options \
	--pidfile --detach

/bin/rm -f /var/log/openvswitch/ovs-vswitchd.log

# Now intialize the OVS database using 'ovs-vsctl --no-wait init' ..."
$ovs_bin/ovs-vsctl --no-wait init

dpdk_opts=""


#
# Specify OVS should support DPDK ports
#
$ovs_bin/ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true

#
# Enable Vhost IOMMU feature which restricts memory that a virtio device can access.  
# Setting 'vfio-iommu-support' to 'true' enable vhost IOMMU support for all vhost ports
#
$ovs_bin/ovs-vsctl --no-wait set Open_vSwitch . other_config:vhost-iommu-support=true

# 8 NUMA nodes
$ovs_bin/ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem=1024,1024,1024,1024,1024,1024,1024,1024

sudo su -g qemu -c "umask 002; $ovs_sbin/ovs-vswitchd $dpdk_opts unix:$DB_SOCK --pidfile --log-file=/var/log/openvswitch/ovs-vswitchd.log --detach"

$ovs_bin/ovs-vsctl --no-wait init

ovs_dpdk_interface_0_name="dpdk-0"
pci_dev="0000:21:00.0"
ovs_dpdk_interface_0_args="options:dpdk-devargs=${pci_dev}"
log "ovs_dpdk_interface_0_args[$ovs_dpdk_interface_0_args]"

ovs_dpdk_interface_1_name="dpdk-1"
pci_dev="0000:21:00.1"
ovs_dpdk_interface_1_args="options:dpdk-devargs=${pci_dev}"
log "ovs_dpdk_interface_1_args[$ovs_dpdk_interface_1_args]"


$ovs_bin/ovs-vsctl --if-exists del-br ovsbr0
$ovs_bin/ovs-vsctl add-br ovsbr0 -- set bridge ovsbr0 datapath_type=netdev
$ovs_bin/ovs-vsctl add-port ovsbr0 ${ovs_dpdk_interface_0_name} -- set Interface ${ovs_dpdk_interface_0_name} type=dpdk ${ovs_dpdk_interface_0_args}
$ovs_bin/ovs-vsctl add-port ovsbr0 ${ovs_dpdk_interface_1_name} -- set Interface ${ovs_dpdk_interface_1_name} type=dpdk ${ovs_dpdk_interface_1_args}
$ovs_bin/ovs-ofctl del-flows ovsbr0
$ovs_bin/ovs-ofctl del-flows ovsbr0 
$ovs_bin/ovs-ofctl add-flow ovsbr0 action=NORMAL
ovs_ports=2


$ovs_bin/ovs-vsctl set interface ${ovs_dpdk_interface_0_name} options:n_rxq=1
$ovs_bin/ovs-vsctl set interface ${ovs_dpdk_interface_1_name} options:n_rxq=1


$ovs_bin/ovs-vsctl set Interface ${ovs_dpdk_interface_0_name} options:n_txq_desc=2048
$ovs_bin/ovs-vsctl set Interface ${ovs_dpdk_interface_0_name} options:n_rxq_desc=2048
$ovs_bin/ovs-vsctl set Interface ${ovs_dpdk_interface_1_name} options:n_txq_desc=2048
$ovs_bin/ovs-vsctl set Interface ${ovs_dpdk_interface_1_name} options:n_rxq_desc=2048


$ovs_bin/ovs-vsctl set Open_vSwitch . other_config:pmd-cpu-mask=0x20000000000000000000000000000000200000000

$ovs_bin/ovs-appctl dpif-netdev/pmd-rxq-show
