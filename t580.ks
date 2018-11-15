#version=DEVEL
install 
url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates
repo --name=fedora

ignoredisk --only-use=vda

# System bootloader configuration
bootloader --location=mbr --boot-drive=vda

# Use text install
text

# Keyboard layouts
keyboard --vckeymap=es --xlayouts='es'

# System language
lang es_ES.UTF-8

# Network information
network  --bootproto=dhcp --device=ens3 --ipv6=auto --activate
network  --hostname=gargantua

# Root password
rootpw --iscrypted $6$B0FlFEk6y3MHIqn0$AFXkVx1nixC7RAGvVOjN27NwsQyIMvkb4vVC2uBjpd7Us5zFY40X.L879MR.nHsVgnYQDCKRxewCw3inRNtmL0

# X Window System configuration information
xconfig  --startxonboot

# Run the Setup Agent on first boot
firstboot --enable

# System services
services --enabled="chronyd"

# System timezone
timezone Europe/Madrid --isUtc

# Reboot after install
reboot

# Add user
user --name=flloreda --groups=weel --password=$6$RQNtSGuG9xWnTQcr$rZ9kGLbVganeTAbtwDFTe.RokABaRurYaQrFNngYlsX1sPU9/CMmDF0yhlqBlS8xPjU3Yh8o9NpO68Edx1/Sr. --iscrypted --gecos="Francisco Lloreda"

# Partition clearing information
clearpart --all --initlabel --drives=vda
zerombr

# Disk partitioning information
part /boot --fstype="ext4" --ondisk=vda --size=1024 --label=boot
part /boot/efi --fstype="efi" --ondisk=vda --size=200 --fsoptions="defaults,uid=0,gid=0,umask=077,shortname=winnt"
part pv.312 --fstype="lvmpv" --ondisk=vda --size=19455 --encrypted --passphrase="secreto123." --grow
volgroup vg_root --pesize=4096 pv.312
logvol swap --fstype="swap" --size=2048 --name=swap --vgname=vg_root
logvol /home --fstype="ext4" --size=3072 --label="home" --name=lv_home --vgname=vg_root
logvol / --fstype="ext4" --size=15380 --label="root" --name=lv_root --vgname=vg_root

%packages
@core

%end

%addon com_redhat_kdump --disable --reserve-mb='128'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

%post --log /root/anaconda.log
dnf groupinstall -y workstation-product-environment
dnf update -y
systemctl set-default graphical.target
systemctl enable gdm.service

cd /root

sh -c "$(curl -sSL https://raw.githubusercontent.com/e-minguez/laptop_install/master/bootstrap.sh)"

ansible-playbook -i inventory -e @myvars.yaml ansible/all.yaml


%end
