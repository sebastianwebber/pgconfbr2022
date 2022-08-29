#!/bin/bash -xe

echo zfs >/etc/modules-load.d/zfs.conf

# for directory in /lib/modules/*; do
#   kernel_version=$(basename $directory)
#   dkms autoinstall -k $kernel_version
# done


zpool create database /dev/sdb
zfs create -o recordsize=8k -o mountpoint=/var/lib/pgsql/14/data database/pgdata