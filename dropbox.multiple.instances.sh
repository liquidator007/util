#!/bin/bash
 
#*******************************
# Multiple dropbox instances
#*******************************
 
dropboxes="isabel jorge"

dropbox=.dropbox 

for USER in $dropboxes
do
    echo Usuario $USER
    HOME=/home/$USER
    if ! [ -d $HOME/$dropbox ];then
        sudo mkdir $HOME/$dropbox
        sudo chown $USER $HOME/$dropbox 
        sudo ln -s $HOME/.Xauthority $HOME/$dropbox/ 
    fi
 
    sudo HOME=$HOME/$dropbox /usr/bin/dropbox start -i
    sudo chown -R $USER $HOME/$dropbox 
done
