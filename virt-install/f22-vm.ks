# System authorization information
auth --enableshadow --passalgo=sha512
# Use network installation
url --url="http://download.eng.bos.redhat.com/released/F-22/GOLD/Server/x86_64/os/"
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
#network  --hostname=dhcp31-246.perf.lab.eng.bos.redhat.com
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
kernel-devel
%end
#network-tools
#systemtap
#@additional-devel
#@development
#@network-file-system-client
#@virtualization-client

#%post
#wget -O /etc/yum.repos.d/rhel7x.repo http://perf1.perf.lab.eng.bos.redhat.com/atheurer/repo-files/f21.repo
#yum groupinstall -y "Development Tools" "RPM Development Tools" "Text-based Internet" "System Tools"
#yum install -y kernel-debuginfo kernel-tools
#yum update -y
#wget -O /etc/yum.repos.d/pbench.repo http://pbench.perf.lab.eng.bos.redhat.com/repo/yum.repos.d/perf-dept.repo
#yum install -y net-tools
#yum install -y configtools
#yum install -y pbench
#mkdir /root/.ssh
#chmod 700 /root/.ssh
#wget -O /root/.ssh/id_dsa.pub http://perf1.perf.lab.eng.bos.redhat.com/atheurer/vm-id_dsa.pub
#wget -O /root/.ssh/id_dsa http://perf1.perf.lab.eng.bos.redhat.com/atheurer/vm-id_dsa
#wget -O /root/.ssh/authorized_keys http://perf1.perf.lab.eng.bos.redhat.com/atheurer/authorized_keys
#chmod 600 /root/.ssh/id_dsa /root/.ssh/id_dsa.pub /root/.ssh/authorized_keys
#wget -O "/etc/systemd/system/serial-getty@ttyS1.service" "http://perf1.perf.lab.eng.bos.redhat.com/atheurer/serial-getty@ttyS1.service"
#ln -s /etc/systemd/system/serial-getty@ttyS1.service /etc/systemd/system/getty.target.wants/
#sed -i -e s/^HWADDR.*// /etc/sysconfig/network-scripts/ifcfg-eth0
#/bin/rm -f /etc/hostname
#%end

shutdown
