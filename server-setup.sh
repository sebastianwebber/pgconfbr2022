#!/bin/bash -xe

yum install -y \
    https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm \
    https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
    epel-release

yum install -y kernel-devel
yum install -y zfs

yum upgrade -y kernel kernel-tools-libs kernel-tools

yum install -y postgresql14-server tmux