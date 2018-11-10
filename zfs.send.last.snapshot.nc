#!/bin/bash

#This command uses "nc" (netcat) to avoid compression and speed up the process


if [ $# -lt 4 -o $# -gt 5 ]
then
  printf "\n\nUsage:\n\t$0 filesystem ssh.privkey dest-host dest-dataset [-R]\n\n\n"
  exit 1
fi

LAST=$(/util/zfs.last.snapshot $1)

if [ ! -z "${LAST}" ]
then
  echo zfs send ${5} "${LAST}" \| pv \| ssh -i "${2}" "${3}" zfs recv -Fu "${4}"
  zfs send ${5} "${LAST}" | pv | ssh -i "${2}" "${3}" zfs recv -Fu "${4}"
else
  printf "\nNo snapshots, nothing sent!!!\n\n"
  exit 1
fi
