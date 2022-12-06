#version=RHEL7
#repo --name=pbench --baseurl=http://pbench.perf.lab.eng.bos.redhat.com/repo/$releasever/
# System authorization information
auth --enableshadow --passalgo=sha512

# Use network installation
url --url="http://download-node-02.eng.bos.redhat.com/released/RHEL-7/7.9/Server/x86_64/os/"
# Use text mode install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate
# Root password
rootpw --iscrypted $6$u/KnxAzbRwPmTlO5$hZ.lPbgaDh3Y8XZlDU7R34.yjE9UKsiWR73IOTn/M2cHqKvW5piJrx3FXsibcHFG1Yq3PkQHnZTbC6G.4LEwk/
# Do not configure the X Window System
skipx
# System timezone
timezone US/Eastern --isUtc --ntpservers=10.16.31.254,clock.util.phx2.redhat.com,clock02.util.phx2.redhat.com
# System bootloader configuration
bootloader --location=mbr --boot-drive=vda
autopart --type=plain
# Partition clearing information
clearpart --all --initlabel --drives=vda

%packages
@base
@core
@network-tools
@development
%end

%post
wget -O "/etc/systemd/system/serial-getty@ttyS1.service" "http://perf1.perf.lab.eng.bos.redhat.com/atheurer/serial-getty@ttyS1.service"
ln -s /etc/systemd/system/serial-getty@ttyS1.service /etc/systemd/system/getty.target.wants/
sed -i -e s/^HWADDR.*// /etc/sysconfig/network-scripts/ifcfg-eth0
echo "DEVICE=eth0" >>/etc/sysconfig/network-scripts/ifcfg-eth0
systemctl disable NetworkManager
systemctl enable network
/bin/rm -f /etc/hostname
%end

shutdown
