#!/bin/bash
REPOURL="https://github.com/flloreda/laptop_install.git"
GITDIR="${HOME}/git"
GITREPO="${GITDIR}/laptop_install"

sudo dnf install -y ansible git dnf-plugins-core libselinux-python

mkdir -p ${GITDIR}

git clone ${REPOURL} ${GITREPO}

cd ${GITREPO}

ansible-playbook -i inventory -e @myvars.yaml ansible/all.yaml

echo "Cambiamos el password de root"
passwd

echo "Cambiamos el password de root"
passwd flloreda 

echo "Cambiamos el password del luks"
cryptsetup luksChangeKey /dev/$(lsblk --fs -l | awk '/crypto_LUKS/ { print $1 }') -S 0

echo "Read the README.md file to continue"
