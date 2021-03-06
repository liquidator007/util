#!/bin/bash

################################################################################
# git.tag
################################################################################
# Tag last commit
################################################################################

if [ $# -ne 1 ]
then
  printf "\n\nUsage:\n\t$0 tag\n\n"
  exit 1
fi

git tag -a $1
