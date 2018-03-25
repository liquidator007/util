#!/bin/bash

. /util/vdr.env

echo lista de $D...

ls -1 $D | sort | uniq

df -Tvh $D
