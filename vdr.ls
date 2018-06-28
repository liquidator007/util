#!/bin/bash

################################################################################
# vdr.ls
################################################################################
# list all recordings into VDR partitions
# Note: By default, Linux mounts them on /media/user/vdr1...
# This tool is for VDR users only
################################################################################

if [ $# -ne 0 ]
then
  printf "\n\nUsage:\n\t$0\n\n"
  exit 1
fi

for D in $(./vdr.env) ; do find $D -maxdepth 1 -mindepth 1 -type d -ls -exec basename {} \;; done | sort | uniq
